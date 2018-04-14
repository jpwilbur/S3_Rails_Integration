# Amazon S3 and Ruby on Rails Integration



This is instruction to setup a Ruby on Rails environment on a Ubuntu machine and integrate an S3 bucket to upload files from a web application to that bucket.

### Objective(s)

Learn to setup Rails as well as integrate S3 to that server.

### Prerequisites

Updated Ubuntu system, S3 Bucket

### Services used

Ruby on Rails, S3

## Step 1: Setup Ruby on Rails

First steps are to download the dependencies that Rails and Ruby require. To begin run the following code on your server:

```curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -

echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

sudo apt-get update

sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev nodejs yarn
```



The next step, we need to install Ruby. rbenv is a package that manages this installation.

```cd

git clone https://github.com/rbenv/rbenv.git ~/.rbenv

echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc

echo 'eval "$(rbenv init -)"' >> ~/.bashrc

exec $SHELL

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
```



The last command checks to ensure that you have installed rbenv correctly and that ruby is now on your machine. You should see the ruby version number.

gem install bundler`


This command is to install bundler which is used to install gem packages for your Rails application later from your gemfile.

If you are planning on creating an application, you may want to set up ssh keys on your machine so you can push your code to a remote repository. These instructions can be found online

You will need NodeJS in your environment to run as your Javascript runtime. These lets you use some features for Javascript compilation within your app.

`curl -sL https://deb.nodesource.com/setup\_8.x | sudo -E bash - sudo apt-get install -y nodejs`


Now you can install Rails

`gem install rails`


Run a rehash to get rails going

`rbenv rehash`


Congrats! You have Rails on your machine. However, you need it connected to a DB in order to be a functioning web server.

## Exercise 2: Database Setup

You will need a database running for your application. This portion of the instructions can be replaced with several different services. RDS can be used in the same way with less installation time (but higher connection time).

```sudo sh -c "echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' > /etc/apt/sources.list.d/pgdg.list"

wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -

sudo apt-get update

sudo apt-get install postgresql-common

sudo apt-get install postgresql-9.5 libpq-dev
```



Next step is to make a user.

`sudo service postgresql start`


## Exercise 3: Make an application

We already have an application that you can work with for this. cd into the directory you would like it in.

`git clone git@github.com:jpwilbur/S3\_Rails\_Integration.git`


Yay. You have an app.

## Exercise 4: Setup integration for AWS to connect to application

Well, you have a very nice looking application running now. Well, not really. You have code for one. But it does absolutely nothing right now. Let's change that.

This step will be your "AWS" portion.

First off, we need to make sure we have keys to access our bucket from our application so that AWS can authorize our application. If you have previously made keys, you can go ahead and skim over this part.

The ideal here would be to create a IAM user that is our "Contributor" or something that represents some entity that can upload and get our objects from our bucket. The second method, if you want to give this application a little more power is to grant it access through the root's access keys. Either method will work. We are simply going to use the root user's keys. The steps are almost identical for an IAM user, except in this case, we are on the root users account receiving keys.

Go to the area on the picture on your console. This will bring up the security portion of your root account.

More than likely, you will get a dialog of AWS saying what I said above: you could do this same thing through a IAM user. This would work as well. If you want to do that, go right on ahead. Users can be given different roles within the system and as those are changed, the keys associated with them will be limited along with them. These keys you are making can do anything with the AWS account. That's why it's telling you this.

Click Continue if you are getting this message (again, unless you want to make a role and get keys there. Your call. Very similar steps, plus choosing roles for that user, in our case is "Put" and "Get" S3 roles.

Now go to Access Keys on your little accordion on your dashboard. If the button to create keys is greyed out, you have more than two keys. Which means you've done this before, which means you need to get those keys. If you've lost them, tough luck. You need to probably delete one of those (hopefully it isn't connected to anything) and get new ones. That secret key that you get shows up ONCE. ONE TIME. You get it here or you don't get it at all. So go ahead and get new keys, and save that csv it gives you for long term storage. For now, copy those access and secret keys it gives you somewhere handy.

Ok, now to use these magical keys.

Go to your Ubuntu terminal in your application's main directory and input the following:

`nano .env`


You will now have a blank nano page. Congrats. You will need to input the following info in there, of course replacing the placeholders with your secret keys (you DO NOT NEED QUOTATION MARKS). Also, your bucket's region is the endpoint, code form the region. You can find the one you used [here](https://docs.aws.amazon.com/general/latest/gr/rande.html#apigateway_region):

```AWS\_ACCESS\_KEY\_ID=INSERT\_YOUR\_ACCESS\_KEY\_ID\_HERE AWS\_SECRET\_ACCESS\_KEY=INSERT\_YOUR\_SECRET\_KEY\_HERES3\_BUCKET=INSERT\_YOUR\_BUCKET\_NAMES3\_REGION=INSERT\_YOUR\_BUCKET'S\_REGION 
```


Tada!! Your ruby app will use this file to input these global variables where it's needed. We will see them soon. This file is apart of the .gitignore file, which means it wont be put into the remote repo, therefore, no one has your keys. Smart, huh?

Go on over to a file for me. (you may have to change it according to where you put it and where you are in the system)

`nano config/initializers/aws.rb`


This is where the magic happens. Remember that `.env` file? Well this is the place that needed it. Those placeholders you see will be replaced with the info you gave that `.env` file. Neato.

How about another?

`nano app/controllers/uploads\_controller.rb`


I'm assuming you're familiar with an mvc controller. This is Rails' controller that facilitates the upload of your file.

The create method is your best friend here. It creates an S3 object, uploads that file with a status (if you want to add some javascript to tell the user that it failed, this is a great place)

Then we take that upload and store its public url in the S3 bucket to your databases as an Upload object. Cool, huh?

Your index simply goes into that table and spits out all the objects you have stored. If you navigate one directory back and go into your "views" directory, then into the uploads directory, you can go into the index file and see that it simply takes those uploads objects and outputs them as links, provided by the public url when you uploaded the object. Cool, right?

Now that I did the boring stuff, lets get the app running so you can give it a shot.

Run the following:

`bundle install rake db:create && rake db:migrate rails server`


Go to your browser and navigate to localhost:3000

It's simple, but it works. Go ahead and make a small file. Like a text file or something and browse for it, then hit "Upload."

You should see a list of uploaded files now! You have successfully uploaded to an S3 bucket from your rails server!
