# Wraps the finished GamingFox folder into an .rpm for Fedora / Hollow OS.
# rpmbuild -bb --define "gf_version 161.0" --define "gf_release 1" --define "gf_tarball /path/gamingfox.tar.xz" \
#          --define "gf_root /path/to/repo" --define "gf_privlibs ^(libxul\\.so|...)" gamingfox.spec
%global debug_package %{nil}
%global __os_install_post %{nil}
%global _build_id_links none
# The browser carries its own private libraries: don't advertise them, and don't require them from elsewhere.
%global __provides_exclude_from ^%{_libdir}/gamingfox/.*$
%global __requires_exclude %{gf_privlibs}

Name:           gamingfox
Version:        %{gf_version}
Release:        %{gf_release}
Summary:        GamingFox: a web browser for gamers, built on the Firefox engine
License:        MPL-2.0
URL:            https://github.com/jdj212223-ctrl/gamingfox
ExclusiveArch:  x86_64
Requires:       gtk3
Requires:       hicolor-icon-theme
Recommends:     ffmpeg-libs

%description
GamingFox is a Gecko (Firefox engine) web browser built for gaming PCs: video on the
graphics card (VA-API), low RAM use, cache in memory to spare the SSD, uBlock Origin,
no telemetry, no sponsored content, and a Game Mode that pauses videos and unloads
background tabs while a game runs.

%install
mkdir -p %{buildroot}%{_libdir}/gamingfox %{buildroot}%{_bindir}
tar -xJf %{gf_tarball} -C %{buildroot}%{_libdir}/gamingfox --strip-components=1
ln -s %{_libdir}/gamingfox/gamingfox %{buildroot}%{_bindir}/gamingfox
install -Dm644 %{gf_root}/packaging/gamingfox.desktop %{buildroot}%{_datadir}/applications/gamingfox.desktop
install -Dm644 %{gf_root}/branding/gamingfox.svg %{buildroot}%{_datadir}/icons/hicolor/scalable/apps/gamingfox.svg
for s in 16 32 48 64 128; do
  install -Dm644 %{buildroot}%{_libdir}/gamingfox/browser/chrome/icons/default/default$s.png \
    %{buildroot}%{_datadir}/icons/hicolor/${s}x${s}/apps/gamingfox.png
done

%files
%{_libdir}/gamingfox
%{_bindir}/gamingfox
%{_datadir}/applications/gamingfox.desktop
%{_datadir}/icons/hicolor/*/apps/gamingfox.*
