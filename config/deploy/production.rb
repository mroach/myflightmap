set :stage, :production

server 'kaya.mroach.com',
       user:  'deploy',
       roles: %w{web app db}
