ARG jdk_version=8
FROM openjdk:$jdk_version

ARG EMBULK_VERSION

RUN curl --create-dirs -o ~/.embulk/bin/embulk -L "https://dl.bintray.com/embulk/maven/embulk-$EMBULK_VERSION.jar" \
  && chmod +x ~/.embulk/bin/embulk \
  && echo 'export PATH="$HOME/.embulk/bin:$PATH"' >> ~/.bashrc \
  && source ~/.bashrc
