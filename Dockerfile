FROM perl:5.34
COPY . /usr/src/perldb
WORKDIR /usr/src/perldb
CMD [ "perl", "./perldb.pl" ]
