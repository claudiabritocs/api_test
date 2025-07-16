# puts "Iniciando o seed..."

# ActiveRecord::Base.logger.silence do
#   Faker::UniqueGenerator.clear

#   unique_users = Array.new(100) { |each| "user#{each + 1}_seed@test.com" }
#   users = unique_users.map { |unique| User.find_or_create_by!(login: unique) }
#   puts "Usuários criados: #{users.size}"

#   unique_ips = Array.new(50) { Faker::Internet.ip_v6_address }
#   puts "IPs únicos gerados: #{unique_ips.size}"

#   users_with_ips = users.map.with_index do |user, index|
#     ip = unique_ips[index % 50]
#     { user: user, ip: ip }
#   end

#   posts_per_user = 200_000 / users.size

#   total_posts_created = 0
#   all_post_ids = []

#   users_with_ips.each_with_index do |user_data, index|
#     user = user_data[:user]
#     ip = user_data[:ip]

#     puts "Criando posts para usuário #{user.login} com IP #{ip} (#{index + 1}/100)"

#     posts_data = posts_per_user.times.map do
#       {
#         title: Faker::Lorem.sentence(word_count: 3),
#         body: Faker::Lorem.paragraph(sentence_count: 1),
#         user_id: user.id,
#         ip: ip,
#         created_at: Time.now,
#         updated_at: Time.now
#       }
#     end

#     result = Post.insert_all(posts_data, returning: %w[id])
#     post_ids = result.rows.flatten
#     all_post_ids.concat(post_ids)
#     total_posts_created += post_ids.size
#     puts "Posts criados para #{user.login}: #{post_ids.size}"
#   end

#   puts "Total de posts criados: #{total_posts_created}"


#   posts_to_rate = all_post_ids.sample((all_post_ids.size * 0.75).to_i)
#   puts "Posts selecionados para avaliação: #{posts_to_rate.size}"


#   ratings_data = []

#   posts_to_rate.each do |post_id|
#     rating_user = users.sample

#     ratings_data << {
#       post_id: post_id,
#       user_id: rating_user.id,
#       value: rand(1..5),
#       created_at: Time.now,
#       updated_at: Time.now
#     }
#   end

#   Rating.insert_all(ratings_data) if ratings_data.any?
#   puts "Avaliações criadas: #{ratings_data.size}"

#   puts "Seed finalizado com sucesso!"
#   puts "Contagem final: #{User.count} usuários | #{Post.count} posts | #{Rating.count} avaliações"
# end

require "typhoeus"
require "faker"
require "json"

puts "Iniciando o seed via API..."

BASE_URL        = "http://localhost:3000/api/v1"
TOTAL_USERS     = 100
TOTAL_POSTS     = 200_000
TOTAL_IPS       = 50
RATINGS_PERCENT = 0.75
BATCH_SIZE      = 1000

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

users_with_ips.each_with_index do |user_data, idx|
  user_id = user_data[:user_id]
  ip    = user_data[:ip]

  puts "Criando #{posts_per_user} posts para #{user_data[:login]} com IP #{ip} (#{idx+1}/#{users_with_ips.size})"

  (1..posts_per_user).each_slice(BATCH_SIZE) do |batch|
    hydra = Typhoeus::Hydra.new(max_concurrency: 200)

    batch.each do
      title = Faker::Lorem.sentence(word_count: 3)
      body  = Faker::Lorem.paragraph(sentence_count: 1)

      req = build_request("posts", {
        post: { title: title, body: body, user_id: user_id, ip: ip }
      })

      req.on_complete do |res|
        if res.success?
          json = JSON.parse(res.body) rescue {}
          all_post_ids << json["id"] if json["id"]
        else
          puts "Falha ao criar post (#{res.code}): #{res.body}"
        end
      end

      hydra.queue(req)
    end

    hydra.run
  end
end

puts "Total de posts criados: #{all_post_ids.size}"

posts_to_rate = all_post_ids.sample((all_post_ids.size * RATINGS_PERCENT).to_i)
puts "Avaliando #{posts_to_rate.size} posts (~75%)..."

posts_to_rate.each_slice(BATCH_SIZE) do |batch|
  hydra = Typhoeus::Hydra.new(max_concurrency: 200)

  batch.each do |post_id|
    rating_user = created_users.sample
    value = rand(1..5)

    req = build_request("ratings", {
      rating: { post_id: post_id, login: rating_user, value: value }
    })

    req.on_complete do |res|
      puts "Falha ao avaliar post #{post_id}" unless res.success?
    end

    hydra.queue(req)
  end

  hydra.run
end

puts "Seed finalizado!"
puts "Contagem esperada: #{created_users.size} usuários | #{all_post_ids.size} posts | ~#{posts_to_rate.size} avaliações"
