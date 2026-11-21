# dotfiles

Meus dotfiles e os scripts para deixar um desktop novo pronto rapidamente.

- **Distros suportadas:** openSUSE Tumbleweed (zypper) e Ubuntu e derivados (apt)
- **Desktop:** GNOME
- **Links simbólicos:** [GNU Stow](https://www.gnu.org/software/stow/)
- **Comandos:** [Task](https://taskfile.dev)

Todos os scripts são **não interativos** (a única pausa possível é a senha do `sudo`) e **idempotentes**: dá para rodar de novo quantas vezes quiser, e o que já está instalado ou configurado é pulado.

## Início rápido

```bash
git clone <url-do-repo> ~/dotfiles
cd ~/dotfiles
./bootstrap.sh setup
```

O `bootstrap.sh` instala o `task` em `~/.local/bin` se ele ainda não existir e repassa os argumentos para ele. O `task setup` lê o `/etc/os-release` e roda `task opensuse` ou `task ubuntu`.

> O repositório deve ficar em `~/dotfiles`: o stow cria os links em `$HOME`.

Depois do primeiro setup, **faça logout e login** (para valerem o shell padrão e as extensões do GNOME) e rode `task gnome:install` de novo para ativar as extensões que acabaram de ser instaladas.

## Tasks

Rode `task` (ou `task --list`) para ver todas.

| Task | O que faz |
| --- | --- |
| `setup` | Detecta a distro e roda o setup completo dela |
| `opensuse` / `ubuntu` | Setup completo da distro, na ordem certa |
| `zypper:install` | Pacotes do zypper, do Packman e de repositórios rpm de terceiros |
| `apt:install` | Pacotes do apt |
| `snapd:remove` | Remove os snaps e o snapd, e impede que ele seja reinstalado |
| `flatpak:setup` | Adiciona o Flathub e libera `~/.themes` e `~/.icons` para os apps flatpak |
| `flatpak:install` | Instala (ou atualiza) os pacotes flatpak |
| `softwares:install` | oh-my-zsh e plugins, fnm, sdkman, task e VS Code |
| `softwares:config` | zsh como shell padrão, ghostty como terminal padrão, `fd`, dotfiles (stow), tmux e extensões do VS Code |
| `dotfiles:link` | Só (re)cria os links dos dotfiles |
| `gnome:install` | Instala e ativa as extensões do GNOME |
| `gnome:setup` | Aplica as configurações do `gsettings` |

Ordem do setup completo:

```
opensuse: zypper:install → softwares:install → softwares:config → flatpak:* → gnome:*
ubuntu:   snapd:remove → apt:install → softwares:install → softwares:config → flatpak:* → gnome:*
```

## Dotfiles (stow)

Todos os arquivos na raiz do repositório são linkados em `$HOME`. O que não deve ser linkado está listado no `.stowrc`.

Se já existir um arquivo comum no lugar de um link (por exemplo, um `.zshrc` criado por um instalador ou o `settings.json` criado pelo VS Code), ele é **movido para `~/.dotfiles-backup/<data-hora>/`** e a versão do repositório passa a valer. Nada é apagado.

## Estrutura

```
.
├── bootstrap.sh            # instala o task e repassa argumentos
├── Taskfile.yml            # todas as tasks
├── .stowrc                 # o que o stow ignora
├── .zshrc, .tmux.conf, .config/, ...   # dotfiles linkados em $HOME
├── scripts/
│   ├── lib.sh              # helpers compartilhados (log, read_list, ...)
│   ├── packages/           # apt, zypper, flatpak, snapd
│   ├── desktop_environment/gnome.sh
│   └── misc/softwares.sh
└── resources/              # listas lidas pelos scripts
    ├── packages/<gerenciador>/*.list
    ├── desktop_environment/gnome/{extensions,sets}.list
    └── misc/softwares/     # extensões do VS Code, overrides do tema do tmux
```

Cada script também pode ser executado direto, passando o nome da função:

```bash
bash scripts/misc/softwares.sh tmux_config
```

## Personalizando

Todas as listas aceitam linhas vazias e comentários com `#`.

| Arquivo | Formato |
| --- | --- |
| `resources/packages/{apt,zypper,flatpak}/packages.list` | um pacote por linha |
| `resources/packages/packman/sources.list` | `<url> <alias>` |
| `resources/packages/rpm/sources.list` | URL de uma chave GPG por linha |
| `resources/packages/rpm/keys.list` | `<nome-do-arquivo-repo> <conteúdo do .repo usando \n>` |
| `resources/packages/rpm/packages.list` | pacotes vindos dos repositórios rpm acima |
| `resources/desktop_environment/gnome/extensions.list` | UUID de uma extensão por linha |
| `resources/desktop_environment/gnome/sets.list` | `<schema> <chave> <valor>` |
| `resources/misc/softwares/vscode/extensions.list` | ID de uma extensão por linha |

As listas de `rpm/` são um modelo para apps que vêm de repositórios rpm de terceiros. O VS Code tem uma função própria, `vscode_install`, em `scripts/misc/softwares.sh`, que funciona com zypper e com apt.

## Etapas manuais

- **Temas GTK, ícones e cursor:** instale em `~/.themes` / `~/.icons` e veja os comentários em `gnome_update_theme`.
- **Monitores no GDM:** veja os comentários em `gnome_setup_gdm_monitors`.
