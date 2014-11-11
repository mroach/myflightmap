set :stage, :production

server 'kaya.mroach.com',
  user: 'deploy',
  roles: :all
