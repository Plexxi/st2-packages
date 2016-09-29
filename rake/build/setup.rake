# Depends on SPECS, so the code bellow just makes it work.
#
#

namespace :setup do
  task :all => [:install_artifacts, :configure]

  task :install_artifacts => ['upload:to_testnode', :install_st2_python] do
    pipeline do
      run hostname: opts[:testnode] do |opts|
        with opts.env do
          within opts.artifact_dir do
            execute :bash, "$BASEDIR/scripts/install_os_packages.sh #{opts[:package_list]}"
          end
        end
      end
    end
  end

  task :configure do
    pipeline do
      run hostname: opts[:testnode] do |opts|
        with opts.env do
          if opts.packages.include? 'st2'
            execute :bash, "$BASEDIR/scripts/generate_st2_config.sh"
          end
          if opts.packages.include? 'st2mistral'
            execute :bash, "$BASEDIR/scripts/generate_mistral_config.sh"
          end
        end
      end
    end
  end

  task :install_st2_python do
    # Use st2_python for latest python
    if pipeopts.st2_python == 1
      pipeline do
        run hostname: opts[:buildnode] do |opts|
          execute :rpm, "-ivh http://yum:Plexxi@artifactory.plexxi.com:8081/artifactory/plexxi-yum-devel/plexxi-connect/el7/x86_64/Packages/plexxi-dev-repo-0.1-1.el7.centos.x86_64.rpm"
          execute :yum, "--nogpgcheck -y install st2python"
        end
      end
    end
  end
end
