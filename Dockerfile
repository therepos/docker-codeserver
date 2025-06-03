FROM codercom/code-server:latest

# Set env for pyenv
ENV PYENV_ROOT="/home/coder/.pyenv"
ENV PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"

USER root

# Install pyenv dependencies
RUN apt-get update && apt-get install -y \
    git curl make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev \
    libxmlsec1-dev libffi-dev liblzma-dev \
    python3-pip \
    && apt-get clean

USER coder

# Install pyenv
RUN curl https://pyenv.run | bash

# Install latest Python 3.x version
RUN latest_py=$(pyenv install --list | grep -E "^\s*3\.[0-9]+\.[0-9]+$" | tail -1 | tr -d ' ') && \
    pyenv install "$latest_py" && \
    pyenv global "$latest_py"

# Show installed Python version
RUN python --version && pip install --upgrade pip

# Copy project requirements and install packages
WORKDIR /home/coder/project
COPY requirements.txt .
RUN pip install -r requirements.txt

# Install Python extension for code-server
RUN code-server --install-extension ms-python.python

EXPOSE 8080

# Set a default login password
ENV PASSWORD="password"

