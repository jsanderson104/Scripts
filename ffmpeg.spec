Name:           ffmpeg
Version:        8.1
Release:        1%{?dist}
Summary:        Digital VCR and multimedia streaming server
License:        GPLv3+
URL:            https://ffmpeg.org/
Source0:        https://ffmpeg.org/releases/%{name}-%{version}.tar.xz

BuildRequires:  gcc
BuildRequires:  gcc-c++
BuildRequires:  make
BuildRequires:  nasm >= 2.13
BuildRequires:  pkgconfig
BuildRequires:  alsa-lib-devel
BuildRequires:  bzip2-devel
BuildRequires:  freetype-devel
BuildRequires:  libxcb-devel
BuildRequires:  opus-devel
BuildRequires:  zlib-devel

Requires:       alsa-lib
Requires:       freetype
Requires:       opus

%description
FFmpeg is a leading multimedia framework able to decode, encode, transcode, 
mux, demux, stream, filter, and play video or audio streams across platforms.

%package devel
Summary:        Development files for FFmpeg
Requires:       %{name}%{?_isa} = %{version}-%{release}

%description devel
The %{name}-devel package contains the header files and libraries needed 
to develop applications that interact with FFmpeg.

%prep
%autosetup

%build
echo " PREFIX = %{_prefix}"
echo " BIN = %{_bindir}"
echo " SBIN = %{_sbindir}"
echo " LIB = %{_libdir}"
echo " SYSCONF = %{_sysconfdir}"
echo " DATA = %{_datadir}"
echo " MAN = %{_mandir}"
echo " SHARED = %{_sharedstatedir}"

echo "Changing LIBDIR from lib64 to lib"
%define _libdir %{_prefix}/lib
%define debug_package %{nil}
%define _prefix /usr/local/%{name}

./configure \
    --prefix=%{_prefix} \
    --enable-gpl \
    --enable-shared \
    --disable-static \
    --enable-alsa \
    --enable-libfreetype \
    --enable-libopus \
    --enable-pthreads

%make_build

%install
%make_install


%files
%license LICENSE.md COPYING.GPLv3
%doc README.md
%{_prefix}
%{_bindir}/ffmpeg
%{_bindir}/ffprobe
%{_libdir}/libavcodec.so.*
%{_libdir}/libavdevice.so.*
%{_libdir}/libavfilter.so.*
%{_libdir}/libavformat.so.*
%{_libdir}/libavutil.so.*
%{_libdir}/libswresample.so.*
%{_libdir}/libswscale.so.*
%{_mandir}/man1/ffmpeg*.1*
%{_mandir}/man1/ffprobe*.1*


%changelog
* Wed Jun 10 2026 Package Maintainer <maintainer@example.com> - 8.1.1-1
- Updated to official release version 8.1.1
- Added basic open-source library support
