require "typhoeus"
require "faker"
require "json"

puts "Iniciando o seed via API..."

BASE_URL        = "http://localhost:3000/api/v1"
TOTAL_USERS     = 100
TOTAL_POSTS     = 200_000
TOTAL_IPS       = 50
RATINGS_PERCENT = 0.75
BATCH_SIZE      = 500

def build_request(endpoint, payload)
  Typhoeus::Request.new(
    "#{BASE_URL}/#{endpoint}",
    method: :post,
    headers: { "Content-Type" => "application/json" },
    body: payload.to_json
  )
end

Faker::UniqueGenerator.clear

unique_users = Array.new(TOTAL_USERS) { |unique| "user#{unique + 1}_seed@test.com" }
puts "Gerando #{unique_users.size} usuários únicos..."

created_users = []
unique_users.each do |login|
  response = build_request("users", { login: login }).run

  if response.success?
    parsed = JSON.parse(response.body) rescue {}
    created_users << { login: login, id: parsed["id"] }
  else
    puts "Falha ao criar usuário #{login} (#{response.code})"
  end
end

puts "#{created_users.size} usuários criados/existentes!"

unique_ips = Array.new(TOTAL_IPS) { Faker::Internet.ip_v6_address }
puts "Gerados #{unique_ips.size} IPs únicos!"

users_with_ips = created_users.map.with_index do |user_data, idx|
  ip = unique_ips[idx % TOTAL_IPS]
  {
    login: user_data[:login],
    user_id: user_data[:id],
    ip: ip
  }
end

posts_per_user = TOTAL_POSTS / created_users.size

all_post_ids = []

hydra = Typhoeus::Hydra.new(max_concurrency: 30)

users_with_ips.each_with_index do |user_data, idx|
  ip = user_data[:ip]

  puts "Criando #{posts_per_user} posts para #{user_data[:login]} com IP #{ip} (#{idx+1}/#{users_with_ips.size})"

  buffer = []

  posts_per_user.times do
    buffer << {
      title: Faker::Lorem.sentence(word_count: 3),
      body:  Faker::Lorem.paragraph(sentence_count: 1),
      login: user_data[:login],
      ip: ip
    }

    if buffer.size >= BATCH_SIZE
      req = build_request("posts/batch_create", { posts: buffer.dup })

      req.on_complete do |response|
        if response.success?
          parsed = JSON.parse(response.body) rescue {}

          if parsed["created_ids"]
            all_post_ids.concat(parsed["created_ids"])
          end

          puts "Batch #{buffer.size} para #{user_data[:login]} enviado"
        else
          puts "Falhou batch: #{response.code} => #{response.body}"
        end
        sleep 0.2
      end

      hydra.queue(req)
      buffer.clear
    end
  end

  unless buffer.empty?
    req = build_request("posts/batch_create", { posts: buffer.dup })
    req.on_complete do |response|
      if response.success?
        parsed = JSON.parse(response.body) rescue {}
        all_post_ids.concat(parsed["created_ids"]) if parsed["created_ids"]
        puts "Último batch (#{buffer.size}) enviado"
      else
        puts "Falhou último batch"
      end
    end
    hydra.queue(req)
  end
end

puts "🚀 Enviando todas requisições em paralelo..."
hydra.run

puts "Total de posts criados: #{all_post_ids.size}"

posts_to_rate = all_post_ids.sample((all_post_ids.size * RATINGS_PERCENT).to_i)
puts "Avaliando #{posts_to_rate.size} posts (~75%)..."

failed_posts = []

posts_to_rate.each_slice(BATCH_SIZE) do |batch|
  hydra = Typhoeus::Hydra.new(max_concurrency: 50)

  batch.each do |post_id|
    rating_user = created_users.sample
    value = rand(1..5)

    req = build_request("ratings", {
      rating: { post_id: post_id, user_id: rating_user[:id], value: value }
    })

    req.on_complete do |res|
      unless res.success?
        puts "Falha ao avaliar post #{post_id}"
        failed_posts << post_id
      end
    end

    hydra.queue(req)
  end

  hydra.run
end

puts "Primeira rodada de ratings concluída. Falharam #{failed_posts.size} posts."

if failed_posts.any?
  puts "Retentando #{failed_posts.size} posts que falharam..."
  retry_failed = []

  failed_posts.each_slice(BATCH_SIZE) do |batch|
    hydra = Typhoeus::Hydra.new(max_concurrency: 100)

    batch.each do |post_id|
      rating_user = created_users.sample
      value = rand(1..5)

      req = build_request("ratings", {
        rating: { post_id: post_id, user_id: rating_user[:id], value: value }
      })

      req.on_complete do |res|
        retry_failed << post_id unless res.success?
      end

      hydra.queue(req)
    end

    hydra.run
  end

  puts "Retry concluído. Ainda falharam #{retry_failed.size} posts."
else
  puts "Nenhum retry necessário!"
end

puts "Seed finalizado!"
puts "Contagem esperada: #{created_users.size} usuários | #{all_post_ids.size} posts | ~#{posts_to_rate.size} avaliações"
