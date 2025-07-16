# API Test – Ruby on Rails

API simples em **Ruby on Rails 8.0.2** para gerenciar **Usuários**, **Posts** e **Avaliações (Ratings)**.

---

## Tecnologias

- Ruby 3.4.4  
- Rails 8.0.2  
- PostgreSQL  
- Faker (geração de dados fake)  
- Typhoeus (requisições paralelas para seeds)  
- Sidekiq (jobs em background, painel em /sidekiq)  
- Rubocop  
- Minitest  

---

## Como rodar o projeto, exemplos de uso e Sidekiq

```bash
# Instalar dependências
bundle install

# Criar e migrar o banco e popular com seed
rails db:setup

# Subir o servidor (http://localhost:3000)
rails s

# Iniciar o Sidekiq em outra aba/terminal
bundle exec sidekiq

# Acessar o painel do Sidekiq
http://localhost:3000/sidekiq

# Listar IPs e seus usuários
curl -X GET http://localhost:3000/api/v1/users/by_ip -H "Content-Type: application/json"

# Criar um novo rating
curl -X POST http://localhost:3000/api/v1/ratings -H "Content-Type: application/json" -d '{"rating":{"post_id":1,"user_id":1,"value":1}}'

# Criar um novo post (com um usuário ainda não existente)
curl -X POST http://localhost:3000/api/v1/posts -H "Content-Type: application/json" -d '{"post":{"title":"Post via curl","body":"Conteúdo via curl","login":"teste_curl@test.com"}}'

# Listar os melhores posts (por média de avaliação)
curl -X GET http://localhost:3000/api/v1/posts/best -H "Content-Type: application/json"

# Rodar testes
rails test
