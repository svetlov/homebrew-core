class Pdf2htmlex < Formula
  desc "PDF to HTML converter"
  homepage "https://coolwanglu.github.io/pdf2htmlEX/"
  url "https://github.com/coolwanglu/pdf2htmlEX/archive/v0.14.6.tar.gz"
  sha256 "320ac2e1c2ea4a2972970f52809d90073ee00a6c42ef6d9833fb48436222f0e5"
  revision 5

  head "https://github.com/coolwanglu/pdf2htmlEX.git"

  bottle do
    sha256 "709f57362811e1613254d3645daf9787e0b16c5507c6a91eb61e54390c3db8bc" => :el_capitan
    sha256 "740829abbb20d8f781e25867047b2c9a22b69aed0a8f0504e2a6bd4b13635ee6" => :yosemite
    sha256 "4513bc5851bae88ed0986504ad9288c80be0f376200b2a9fc5976c784627a52f" => :mavericks
    sha256 "c937bffad3460d6a6adf244073e31844a6091a679523bba3060092bc7ae5fe90" => :x86_64_linux
  end

  depends_on :macos => :lion
  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "poppler"
  depends_on "gnu-getopt"
  depends_on "ttfautohint" => :recommended if MacOS.version > :snow_leopard

  # Fontforge dependencies
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :run
  depends_on "glib"
  depends_on "pango"
  depends_on "gettext"
  depends_on "libpng"   => :recommended
  depends_on "jpeg"     => :recommended
  depends_on "libtiff"  => :recommended

  # Pdf2htmlex use an outdated, customised Fontforge installation.
  # See https://github.com/coolwanglu/pdf2htmlEX/wiki/Building
  resource "fontforge" do
    url "https://github.com/coolwanglu/fontforge.git", :branch => "pdf2htmlEX"
  end

  # And failures
  fails_with :llvm do
    build 2336
    cause "Compiling cvexportdlg.c fails with error: initializer element is not constant"
  end

  def install
    resource("fontforge").stage do
      args = %W[
        --prefix=#{prefix}/fontforge
        --without-libzmq
        --without-x
        --without-iconv
        --disable-python-scripting
        --disable-python-extension
      ]

      # Fix linker error; see: https://trac.macports.org/ticket/25012
      ENV.append "LDFLAGS", "-lintl" if OS.mac?

      # Reset ARCHFLAGS to match how we build
      ENV["ARCHFLAGS"] = "-arch #{MacOS.preferred_arch}"

      system "./autogen.sh"
      system "./configure", *args

      system "make"
      system "make", "install"
    end

    # Prepend the paths to always find this dep fontforge instead of another.
    ENV.prepend_path "PKG_CONFIG_PATH", "#{prefix}/fontforge/lib/pkgconfig"
    ENV.prepend_path "PATH", "#{prefix}/fontforge/bin"
    system "cmake", ".", *std_cmake_args
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/pdf2htmlEX", test_fixtures("test.pdf")
  end
end
