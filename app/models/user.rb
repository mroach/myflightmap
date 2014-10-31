class User < ActiveRecord::Base
  audited

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]

  validates :username,
    uniqueness: true,
    exclusion: { in: %w(
      airline airlines airport airports devise flight flights
      import layouts trips myflightmap
      about ac access account accounts activate ad add address adm admin administration administrator adult advertising ae af affiliate affiliates ag ai ajax al am an analytics android anon anonymous ao api app apple apps aq ar arabic archive archives as at atom au auth authentication avatar aw awadhi ax az azerbaijani ba backup banner banners bb bd be bengali better bf bg bh bhojpuri bi billing bin bj blog blogs bm bn bo board bot bots br bs bt burmese business bv bw by bz ca cache cadastro calendar campaign cancel careers cart cc cd cf cg cgi ch changelog chat checkout chinese ci ck cl client cliente cm cn co code codereview comercial compare compras config configuration connect contact contest cr create cs css cu cv cvs cx cy cz dashboard data db dd de delete demo design designer dev devel dir direct direct_messages directory dj dk dm do doc docs documentation domain download downloads dutch dz ec ecommerce edit editor edits ee eg eh email employment english enterprise er es et eu exchange facebook faq farsi favorite favorites feed feedback feeds fi file files fj fk fleet fleets flog fm fo follow followers following forum forums fr free french friend friends ftp ga gadget gadgets games gan gb gd ge german gf gg gh gi gist git github gl gm gn google gp gq gr group groups gs gt gu guest gujarati gw gy hakka hausa help hindi hk hm hn home homepage host hosting hostmaster hostname hpg hr ht html http httpd https hu id idea ideas ie il im image images imap img in index indice info information intranet invitations invite io ipad iphone iq ir irc is it italian japanese java javanese javascript je jinyu jm jo job jobs jp js json kannada ke kg kh ki km kn knowledgebase korean kp kr kw ky kz la language languages lb lc li list lists lk local localhost log login logout logs lr ls lt lu lv ly ma mail mail1 mail2 mail3 mail4 mail5 mailer mailing maithili malayalam manager mandarin map maps marathi marketing master mc md me media message messenger mg mh microblog microblogs min-nan mine mis mk ml mm mn mo mob mobile mobilemail movie movies mp mp3 mq mr ms msg msn mt mu music musicas mv mw mx my mysql mz na name named nc ne net network new news newsletter nf ng ni nick nickname nl no notes noticias np nr ns ns1 ns2 ns3 ns4 nu nz oauth oauth_clients offers old om online openid operator order orders organizations oriya pa page pager pages panel panjabi password pda pe perl pf pg ph photo photoalbum photos php pic pics pk pl plans plugin plugins pm pn polish pop pop3 popular portuguese post postfix postmaster posts pr privacy profile project projects promo ps pt pub public put pw py python qa random re recruitment register registration remove replies repo ro romanian root rs rss ru ruby russian rw sa sale sales sample samples save sb sc script scripts sd se search secure security send serbo-croatian service sessions setting settings setup sftp sg sh shop si signin signup sindhi site sitemap sites sj sk sl sm smtp sn so soporte spanish sql sr ss ssh ssl ssladmin ssladministrator sslwebmaster st stage staging start stat static stats status store stores stories styleguide su subdomain subscribe subscriptions sunda suporte support sv svn sy sysadmin sysadministrator system sz tablet tablets talk tamil task tasks tc td tech telnet telugu terms test test1 test2 test3 teste tests tf tg th thai theme themes tj tk tl tm tmp tn to todo tools tour tp tr translations trends tt turkish tv tw twitter twittr tz ua ug uk ukrainian unfollow unsubscribe update upload urdu url us usage user username usuario uy uz va vc ve vendas vg vi video videos vietnamese visitor vn vu weather web webmail webmaster website websites webstats wf widget widgets wiki win workshop ws wu ww wws www www1 www2 www3 www4 www5 www6 www7 wwws wwww xfn xiang xml xmpp xmppSuggest xpg xxx yaml ye yml yoruba you yourdomain yourname yoursite yourusername yt yu za zm zw
    )},
    length: { minimum: 3 },
    format: { with: /\A ( [[:alnum:]] (\.|_*|\-) )* \z/ix }

  def self.from_omniauth(auth)
    logger.debug auth.info
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.username = generate_username(auth.info)
      user.name = auth.info.name   # assuming the user model has a name
      user.image = auth.info.image # assuming the user model has an image
    end
  end

  # Password is not changeable when using OAuth
  def is_password_changeable?
    self.provider.blank?
  end

  # Take an OmniAuth::AuthHash::InfoHash and generate a username
  def self.generate_username(auth_info)
    # Preferably use the nick name on the account. @ name on GitHub or Twitter, FB nickname, etc.
    username = auth_info.nickname

    # if there's no nick name, use first_name.last_name
    if username.blank?
      username = "#{auth_info.first_name}.#{auth_info.last_name}"
    end

    username = groom_username(username)

    # If the username is in use, add a number
    # Ex) john.smith => john.smith3
    base_username = username
    i = 1
    while exists?(username: username)
      username = "#{base_username}#{i}"
      i = i + 1
    end

    username
  end

  def self.groom_username(name)
    name.downcase
        .sub(/\s/, '')    # strip spaces
        .sub(/^+\W/, '')  # strip leading non-words
        .sub(/\W+$/, '')  # strip trailing non-words
  end
end
