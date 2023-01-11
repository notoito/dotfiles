export DOTFILES_DIR="${HOME}/dotfiles"

export EDITOR=vim

export N_PREFIX=$HOME/.n
export PATH=$N_PREFIX/bin:$PATH

if [ -e "${DOTFILES_DIR}/resources/.zprofile.d/user.local.sh" ] ; then
  . "${DOTFILES_DIR}/resources/.zprofile.d/user.local.sh"
fi

if [ -e "${DOTFILES_DIR}/resources/.zprofile.d/generated.local.sh" ] ; then
  . "${DOTFILES_DIR}/resources/.zprofile.d/generated.local.sh"
fi