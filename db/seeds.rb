puts "Iniciando o seed..."

ActiveRecord::Base.logger.silence do
  Faker::UniqueGenerator.clear

  unique_users = Array.new(100) { |each| "user#{each + 1}_seed@test.com" }
  users = unique_users.map { |unique| User.find_or_create_by!(login: unique) }
  puts "Usuários criados: #{users.size}"

  unique_ips = Array.new(50) { Faker::Internet.ip_v6_address }
  puts "IPs únicos gerados: #{unique_ips.size}"

  users_with_ips = users.map.with_index do |user, index|
    ip = unique_ips[index % 50]
    { user: user, ip: ip }
  end

  posts_per_user = 200_000 / users.size

  total_posts_created = 0
  all_post_ids = []

  users_with_ips.each_with_index do |user_data, index|
    user = user_data[:user]
    ip = user_data[:ip]

    puts "Criando posts para usuário #{user.login} com IP #{ip} (#{index + 1}/100)"

    posts_data = posts_per_user.times.map do
      {
        title: Faker::Lorem.sentence(word_count: 3),
        body: Faker::Lorem.paragraph(sentence_count: 1),
        user_id: user.id,
        ip: ip,
        created_at: Time.now,
        updated_at: Time.now
      }
    end

    result = Post.insert_all(posts_data, returning: %w[id])
    post_ids = result.rows.flatten
    all_post_ids.concat(post_ids)
    total_posts_created += post_ids.size
    puts "Posts criados para #{user.login}: #{post_ids.size}"
  end

  puts "Total de posts criados: #{total_posts_created}"


  posts_to_rate = all_post_ids.sample((all_post_ids.size * 0.75).to_i)
  puts "Posts selecionados para avaliação: #{posts_to_rate.size}"


  ratings_data = []

  posts_to_rate.each do |post_id|
    rating_user = users.sample

    ratings_data << {
      post_id: post_id,
      user_id: rating_user.id,
      value: rand(1..5),
      created_at: Time.now,
      updated_at: Time.now
    }
  end

  Rating.insert_all(ratings_data) if ratings_data.any?
  puts "Avaliações criadas: #{ratings_data.size}"

  puts "Seed finalizado com sucesso!"
  puts "Contagem final: #{User.count} usuários | #{Post.count} posts | #{Rating.count} avaliações"
end
