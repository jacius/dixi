
desc "Run Dixi in development mode."
task :shotgun do
  sh( "shotgun --port 4567 --env development config.ru"  )
end


desc "Create capconfig.yaml template."
task :capconfig do
  if File.exist?("capconfig.yaml")
    puts "ERROR: capconfig.yaml already exists! Aborting."
  else
    File.open("capconfig.yaml","w") { |f|
      f.write("---
# This is just a template. Change it to your own deployment details!
:user: some_user
:domain: my.domain.com
:repository: git://repo.to.use/from/the/server.git
:local_repository: ssh://repo.to.use/from/your/computer.git
:deploy_to: /home/some_user/my.domain.com/
:branch: master")
    }
    puts "Created capconfig.yaml. Edit it now to fill in your details."
  end
end



desc "Generate indexes for all projects."
task :index do
  require 'dixi'
  Dixi.projects.each do |project|
    project.all_versions.each do |version|
      p = project.at_version( version )
      print "Generating index for #{project.name} #{version}... "
      begin
        i = Dixi::Index.new( p )
        i.generate
        puts "Done. (#{i.size} entries)"
      rescue => e
        puts "ERROR: #{e}"
      end
    end
  end
end


#########
# SPECS #
#########

begin
  require 'spec/rake/spectask'

  desc "Run all specs"
  Spec::Rake::SpecTask.new do |t|
    t.spec_files = FileList['spec/*_spec.rb']
  end

  namespace :spec do
    desc "Run all specs"
    Spec::Rake::SpecTask.new(:all) do |t|
      t.spec_files = FileList['spec/*_spec.rb']
    end

    desc "Run spec/[name]_spec.rb (e.g. 'color')"
    task :name do
      puts( "This is just a stand-in spec.",
            "Run rake spec:[name] where [name] is e.g. 'color', 'music'." )
    end
  end


  rule(/spec:.+/) do |t|
    name = t.name.gsub("spec:","")

    path = File.join( File.dirname(__FILE__),'spec','%s_spec.rb'%name )

    if File.exist? path
      Spec::Rake::SpecTask.new(name) do |t|
        t.spec_files = [path]
      end

      puts "\nRunning spec/%s_spec.rb"%name

      Rake::Task[name].invoke
    else
      puts "File does not exist: %s"%path
    end

  end

rescue LoadError

  error = "ERROR: RSpec is not installed?"

  task :spec do 
    puts error
  end

  rule( /spec:.*/ ) do
    puts error
  end

end
