
# https://hub.docker.com/r/amazon/aws-cli
# alias aws-cli="docker run --rm -ti -v ~/.aws:/root/.aws -v \$(pwd):/aws amazon/aws-cli"

# to update:
# `docker pull amazon/aws-cli:latest`
alias aws-cli="docker run --rm -ti -v ~/.aws:/.aws -v \$(pwd):/aws --user=\$(id -u):\$(getent group \$(id -g) | cut -d ':' -f 3) amazon/aws-cli"

