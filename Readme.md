# Tumblr Import

Tumblr Import is a simple utility to import the posts of on your wordpress blog into a Tumblr Microblog

## Prerequisites

To use this program, you'll need a [Tumblr OAuth Key](http://www.tumblr.com/oauth/apps) and a Wordpress XML export file.
You can obtain a wordpress XML file from  your wordpress administration console. Look under "Tools" on the Admin sidebar.

## Usage

1. Get your Oauth key and XML export file as described above
2. Copy `tumblr_import.example.yml` to `tumblr_import.yml` and change the properties to what you aquired
3. Open your browser and navigate to `http://localhost:4567/start`
4. Click "Allow" when Tumblr asks if you want to allow this application
5. Wait for it to finish, it will take a few minutes.

## Known Issues

1. Tumblr's HTML is more restrictive than Wordpress's. You will lose some formatting from your posts.
2. This script does not migrate self-hosted images from wordpress.
3. Tumblr does not natively support comments. They will be lost.

## Acknowledgements

I used [this gist](https://gist.github.com/194339) as a starting point for parsing the wordpress xml and posting to the api.