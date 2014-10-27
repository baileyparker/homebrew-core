require "formula"

class Libmongoclient < Formula
  homepage "http://www.mongodb.org"
  url "https://github.com/mongodb/mongo-cxx-driver/archive/legacy-0.0-26compat-2.6.5.tar.gz"
  sha1 "1cc66854eac8cb79457ec68ba24153b321263430"

  head "https://github.com/mongodb/mongo-cxx-driver.git", :branch => "26compat"

  bottle do
    sha1 "4cfc88b78420b4346459b5cbdb82bf3eac632ede" => :mavericks
    sha1 "89199bb5d9f0a21ef133834f7c9be4d7701a8210" => :mountain_lion
    sha1 "375548f6c620f30b59d3188af3d3d72f79d830a7" => :lion
  end

  option :cxx11

  depends_on "scons" => :build

  if build.cxx11?
    depends_on "boost" => "c++11"
  else
    depends_on "boost"
  end

  # Add 10.10 as a recognised OS X version choice.
  # https://github.com/mongodb/mongo-cxx-driver/pull/185
  patch :DATA

  def install
    ENV.cxx11 if build.cxx11?

    boost = Formula["boost"].opt_prefix

    args = [
      "--prefix=#{prefix}",
      "-j#{ENV.make_jobs}",
      "--cc=#{ENV.cc}",
      "--cxx=#{ENV.cxx}",
      "--extrapath=#{boost}",
      "--full",
      "--use-system-all",
      "--sharedclient",
      # --osx-version-min is required to override --osx-version-min=10.6 added
      # by SConstruct which causes "invalid deployment target for -stdlib=libc++"
      # when using libc++
      "--osx-version-min=#{MacOS.version}",
    ]

    args << "--libc++" if MacOS.version >= :mavericks

    scons *args
  end
end

__END__

diff --git a/SConstruct b/SConstruct
index ae0f270..24c8522 100644
--- a/SConstruct
+++ b/SConstruct
@@ -300,7 +300,7 @@ add_option('propagate-shell-environment',
            0, False)

 if darwin:
-    osx_version_choices = ['10.6', '10.7', '10.8', '10.9']
+    osx_version_choices = ['10.6', '10.7', '10.8', '10.9', '10.10']
     add_option("osx-version-min", "minimum OS X version to support", 1, True,
                type = 'choice', default = osx_version_choices[0], choices = osx_version_choices)
