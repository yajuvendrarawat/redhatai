# syntax=docker/dockerfile:1

#FROM nvidia/cuda:12.2.0-devel-ubi9
FROM nvidia/cuda:12.4.1-runtime-ubi9

# Install required libraries and dependencies for Streamlit ==3.10 remove the SQLite error
RUN yum install -y \
    python \
    python-pip \
    python \
    gcc \
    gcc-c++ \
    python-devel \
 && yum clean all

## MAKE ALL BELOW RUN COMMANDS USE THE NEW PYTHON ENVIRONMENT
#RUN echo "alias pip='python3 -m pip'" >> ~/.bashrc

#RUN yum -y update \
#    && yum -y install gcc  \
#    && yum -y install gcc-c++  \
#   && yum -y --allowerasing install curl bzip2 \
#    && curl -sSL https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh \
#    && bash /tmp/miniconda.sh -b -p /opt/conda \
#    && rm -rf /tmp/miniconda.sh && \
#    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
#    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
#    find /opt/conda/ -follow -type f -name '*.a' -delete && \
#    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
#    /opt/conda/bin/conda clean -afy

## ADD CONDA PATH TO LINUX PATH 
#ENV PATH /opt/conda/bin:$PATH

## COPY ENV REQUIREMENTS FILES
COPY ./env_config.yml /tmp/env_config.yml

## CREATE CONDA ENVIRONMENT USING YML FILE
#RUN conda update conda \
#    && conda env create -f /tmp/env_config.yml

## ADD CONDA ENV PATH TO LINUX PATH 
#ENV PATH /opt/conda/envs/myconda/bin:$PATH
#ENV CONDA_DEFAULT_ENV myconda

## MAKE ALL BELOW RUN COMMANDS USE THE NEW CONDA ENVIRONMENT
#RUN echo "conda activate myconda" >> ~/.bashrc

COPY ./requirements.txt . 

RUN --mount=type=cache,target=/root/.cache  pip install --timeout 100 -r requirements.txt

#RUN --mount=type=cache,target=/root/.cache CMAKE_ARGS="-DLLAMA_CUDAS=on" FORCE_CMAKE=1 pip install --upgrade --force-reinstall llama-cpp-python
#COPY SOURCE_DOCUMENTS ./SOURCE_DOCUMENTS
ENV LD_LIBRARY_PATH /usr/local/lib/python3.9/site-packages/nvidia/cudnn/lib/:/usr/local/lib/python3.9/site-packages/nvidia/cuda_cupti/lib/:$LD_LIBRARY_PATH

WORKDIR /app
RUN mkdir SOURCE_DOCUMENTS
COPY . .
RUN chmod +x /app/redhat_ai.py

ENV device_type=cuda

EXPOSE 8501
ENTRYPOINT ["streamlit", "run", "redhat_ai.py", "--server.port=8501", "--server.address=0.0.0.0"]


   

 
