Name:           carch
Version:        4.3.3
Release:        1%{?dist}
Summary:        A Simple Script to Make Linux System Setups Easier
License:        MIT 
URL:            https://github.com/harilvfs/%{name}
Source0:        %{URL}/archive/refs/tags/v%{version}.tar.gz#/%{name}-%{version}.tar.gz

BuildRequires:  cargo
BuildRequires:  rust
BuildRequires:  gcc
BuildRequires:  git

Requires:       bash
Requires:       man-pages
Requires:       man-db
Requires:       git
Requires:       wget
Requires:       figlet
Requires:       dnf
Requires:       fzf
Requires:       google-noto-color-emoji-fonts
Requires:       google-noto-emoji-fonts
Requires:       jetbrains-mono-fonts-all
Requires:       curl
Requires:       gcc
Requires:       glibc

Suggests:       bash-completion-devel

%description
Carch is a simple script to help automating linux system setups. It provides a convenient way to install and
configure packages and system settings.

%prep
%autosetup -p1

%build
export CARGO_TARGET_DIR=target
cargo build --frozen --release --all-features

%install
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_datadir}/licenses/%{name}
mkdir -p %{buildroot}%{_datadir}/doc/%{name}
mkdir -p %{buildroot}%{_datadir}/applications
mkdir -p %{buildroot}%{_mandir}/man1
mkdir -p %{buildroot}%{_datadir}/bash-completion/completions
mkdir -p %{buildroot}%{_datadir}/zsh/site-functions
mkdir -p %{buildroot}%{_datadir}/fish/vendor_completions.d

install -Dm755 target/release/%{name} %{buildroot}%{_bindir}/%{name}
install -Dm644 LICENSE %{buildroot}%{_datadir}/licenses/%{name}/LICENSE
install -Dm644 README.md %{buildroot}%{_datadir}/doc/%{name}/README.md
echo "Version=%{version}" >> %{name}.desktop
install -Dm644 %{name}.desktop %{buildroot}%{_datadir}/applications/%{name}.desktop
install -Dm644 man/%{name}.1 %{buildroot}%{_mandir}/man1/%{name}.1
install -Dm644 completions/bash/%{name} %{buildroot}%{_datadir}/bash-completion/completions/%{name}
install -Dm644 completions/zsh/_%{name} %{buildroot}%{_datadir}/zsh/site-functions/_%{name}
install -Dm644 completions/fish/%{name}.fish %{buildroot}%{_datadir}/fish/vendor_completions.d/%{name}.fish
for size in 16 24 32 48 64 128 256; do
    install -Dm644 assets/icons/product_logo_${size}.png \
        %{buildroot}%{_datadir}/icons/hicolor/${size}x${size}/apps/%{name}.png
done

%files
%license LICENSE
%doc README.md
%{_bindir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_mandir}/man1/%{name}.1*
%{_datadir}/bash-completion/completions/%{name}
%{_datadir}/zsh/site-functions/_%{name}
%{_datadir}/fish/vendor_completions.d/%{name}.fish
%{_datadir}/icons/hicolor/*/apps/%{name}.png

%changelog
* Tue Apr 15 2025 RPM Builder <harilvfs@chalisehari.com.np> - 4.3.3-1
- Add Carch Installer [ In Rust ]
- Major Bug Fixes
