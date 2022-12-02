name="hyprland-git"
pkgname="${name}"
version=r2042.ga7ed3a5
release=1
desc="A dynamic tiling Wayland compositor based on wlroots that doesn't sacrifice on its looks."
architectures=(any)
homepage="https://github.com/hyprwm/Hyprland"
license=('BSD')
build_deps_fedora=(
	ninja-build
  cmake 
  meson 
  gcc-c++ 
  libxcb-devel 
  libX11-devel pixman-devel 
  wayland-protocols-devel 
  cairo-devel
  pango-devel)
source=("git+https://github.com/hyprwm/Hyprland.git")
conflicts=("${name}")
provides=(hyprland)
sha256sums=('SKIP')
options=(!makeflags !buildflags !strip)

version() {
  cd "$srcdir/$name"
  ( set -o pipefail
    git describe --long 2>/dev/null | sed 's/\([^-]*-g\)/r\1/;s/-/./g' ||
    printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
  )
}

build() {
	cd "${srcdir}/${name}"
	git submodule update --init
	make fixwlr
	cd "./subprojects/wlroots/" && meson build/ --prefix="${srcdir}/tmpwlr" --buildtype=release && ninja -C build/ && mkdir -p "${srcdir}/tmpwlr" && ninja -C build/ install && cd ../../
	make protocols
    make release
	cd ./hyprctl && make all && cd ..
}

package() {
	cd "${srcdir}/${name}"
	mkdir -p "${pkgdir}/usr/share/wayland-sessions"
	mkdir -p "${pkgdir}/usr/share/hyprland"
	install -Dm755 build/Hyprland -t "${pkgdir}/usr/bin"
	install -Dm755 hyprctl/hyprctl -t "${pkgdir}/usr/bin"
	install -Dm644 assets/*.png -t "${pkgdir}/usr/share/hyprland"
	install -Dm644 example/hyprland.desktop -t "${pkgdir}/usr/share/wayland-sessions"
	install -Dm644 example/hyprland.conf -t "${pkgdir}/usr/share/hyprland"
	install -Dm644 LICENSE -t "${pkgdir}/usr/share/licenses/${name}"
	install -Dm755 ../tmpwlr/lib/libwlroots.so.12032 -t "${pkgdir}/usr/lib"
}
