class App < Sinatra::Base
	enable :sessions

	get '/index' do
		slim(:index)
	end

	get '/ekicks' do
		slim(:ekicks)
	end	
	
	get '/login' do
		slim(:login)
	end

	get '/register' do
		slim (:register)
	end

	get '/error' do
		slim(:error, locals:{msg:session[:message]})
	end	

	post '/login' do
		db = SQLite3::Database.new("db/ekicks.sqlite")
		username = params["username"]
		password = params["password"]
		user_id = db.execute("SELECT id FROM login WHERE username='#{username}'")
		password_digest = db.execute("SELECT password FROM login WHERE username='#{username}'").join
		password_digest = BCrypt::Password.new(password_digest)
		if password_digest == password
			session[:username] = username
			session[:id] = user_id
			redirect('/ekicks')
		else
			redirect('/register')
		end
	end

	post '/register' do
		db = SQLite3::Database.new("db/ekicks.sqlite")
		username = params["username"]
		password = params["password"]
		password2 = params["password2"]
		password_digest = BCrypt::Password.create("#{password}")
		if username.length > 0
			if password == password2 && password.length > 0
				begin
					db.execute("INSERT INTO login (username, password) VALUES (?, ?)", [username,password_digest])
				rescue
					session[:message] = "The username is unavailable"
					redirect('/error')
				end
				redirect('/login')
			else
				session[:message] = "Password unavailable"
				redirect('/error')
			end
		else
			session[:message] = "The username is unavailable"
			redirect('/error')
		end
	end

end           
