require 'erb'
require 'uri'
require 'net/http'
require 'yaml'

# I could've use any ruby library for dealing with
# the GitHub API. I decided not to do so because it would
# require you to install it. In case you want me to show you
# a code example using either octopi or octopussy, just let me know.

TEMPLATE_FILE = File.join(File.dirname(__FILE__), 'template.html.erb')
OUTPUT_FILE = File.join(File.dirname(__FILE__), 'rails_committers.html')
USER_ID = :rails
REPO = :rails

def github(*path)
  "http://github.com/api/v2/yaml/#{path.join('/')}"
end

rhtml = ERB.new(File.read(TEMPLATE_FILE))

commits = YAML.load(Net::HTTP.get_response(URI.parse(github(:commits, :list,  USER_ID, REPO, :master))).body)["commits"]

class LastCommits

  def initialize(commits)
    @email_to_name = {}
    @email_to_commits = {}
    commits.each do |ci|
      email = ci["author"]["email"].to_sym
      @email_to_name[email] = ci["author"]["name"] unless @email_to_name[email]
      (@email_to_commits[email] ||= []) << { :message => ci["message"],
        :url => ci["url"],
        :id  => ci["id"]}
    end
  end

  def get_binding
    binding
  end
end

File.open(OUTPUT_FILE, 'w') do |f|
  f.puts rhtml.result(LastCommits.new(commits).get_binding)
end

