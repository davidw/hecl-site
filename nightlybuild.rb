#!/usr/bin/ruby

require 'fileutils'

FileUtils.cd(File.dirname(__FILE__))

# These files must exist.
requiredfiles =
  ["jars/AndroidBuilder.jar",
   "jars/AppletTweak.jar",
   "jars/HeclBuilder.jar",
   "jars/JarHack.jar",
   "jars/applet/cldc1.0-midp1.0/Hecl.jar",
   "jars/applet/cldc1.1-midp2.0/Hecl.jar",
   "jars/cldc1.0-midp1.0/Hecl.jar",
   "jars/cldc1.0-midp1.0/Hecl.jad",
   "jars/cldc1.1-midp2.0/Hecl.jar",
   "jars/cldc1.1-midp2.0/Hecl.jad",
   "jars/j2se/Hecl.jar",
   "jars/j2se/Heclstand.jar",
   "jars/mwt/Mwtgui.jad",
   "jars/mwt/Mwtgui.jar"]


# Steps to take to build a nightly build.
cmds = ["git pull origin master",
        "nice ant",
        "ant cleanBuild"]

FileUtils.cd("hecl") do
  cmds.each do |c|
    if !system(c)
      STDERR.puts "Error running #{c}"
      exit(1)
    end
  end

  missing = false
  requiredfiles.each do |f|
    if !File.exists?(f)
      STDERR.puts "Missing file: #{f}"
      missing = true
    end
  end
  if missing
    exit(1)
  end
end

# Ok, let's bundle it all up.

tarball = "hecl-#{Time.now.strftime("%Y%m%d")}.tgz"

system("tar czvf #{tarball} hecl/")
FileUtils.mv(tarball, "downloads/")
FileUtils.ln_sf(tarball, "downloads/hecl-latest.tgz")

# Clean up any old ones.

FileUtils.cd("downloads") do
  files = Dir.glob("hecl-*").sort
  if files.length > 10
    files[0..-10].each do |f|
      puts "Deleting old file #{f}"
      File.delete(f)
    end
  end
end

exit(0)
