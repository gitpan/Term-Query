# Makefile for Query module
#
#    Copyright (C) 1995  Alan K. Stebbens <aks@hub.ucsb.edu>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#    $Id: Makefile,v 1.11 1995/10/02 17:37:24 aks Exp $

# Set DEFAULT one or more of install-local, install-net, or install-home
#
# If INSTALL_VER is 'yes', this Makefile installs files both with and
# without versions.  The non-version named is linked to the versioned
# name.  This allows updates of a newer version without completely
# stepping on the older version.  Users preferring the older version
# can do:
#
#	use 'Term::Query-1.12';
#
# If INSTALL_VER is 'no', then only the non-version names are installed.
#
#
# Versioned names:
#
#	/usr/local/perl5/lib/Term/Query-1.12.pm
#	/usr/local/perl5/man/man3/Term::Query-1.12.3p
#
# Non-versioned names:
#
#	/usr/local/perl5/lib/Term/Query.pm
#	/usr/local/perl5/man/man3/Term::Query.3p
#

    MOD_NAME = Query
 
       CLASS = Term

# Set this to 'no', if you do not want version numbers to be installed

 INSTALL_VER = yes

      MODULE = $(LIB)/$(CLASS)/$(MOD_NAME).pm
  MODULE_VER = $(LIB)/$(CLASS)/$(MOD_NAME)-$(VERSION).pm
     VERSION = 0

     DEFAULT = install-local
 
     NETROOT = /eci/perl5
      NETLIB = $(NETROOT)/lib
      NETMAN = $(NETROOT)/man/man$(MANSEC)
  
   LOCALROOT = /usr/local/perl5
    LOCALLIB = $(LOCALROOT)/lib
    LOCALMAN = $(LOCALROOT)/man/man$(MANSEC)
  
    HOMEROOT = $(HOME)
     HOMELIB = $(HOMEROOT)/lib/perl
     HOMEMAN = $(HOME)/man/man$(MANSEC)
  
      MANSEC = 3
      MANSFX = p
     MANPAGE = $(MAN)/$(CLASS)::$(MOD_NAME).$(MANSEC)$(MANSFX)
 MANPAGE_VER = $(MAN)/$(CLASS)::$(MOD_NAME)-$(VERSION).$(MANSEC)$(MANSFX)

   SHARFILES = README Query.pm Makefile tq t ChangeLog Copyright GNU-LICENSE
     ARCHIVE = $(CLASS)-$(MOD_NAME)-$(VERSION)

     FTPHOST = root@hub.ucsb.edu
     FTPHOME = /usr/home/ftp
  FTPDESTDIR = /pub/prog/perl

     POD2MAN = pod2man

         LIB = .phony-lib
         MAN = .phony-man

       SHELL = /bin/sh

help:
	@echo 'make install             Default install ($(DEFAULT))'
	@echo 'make install-net         Install in $(NETLIB)'
	@echo 'make install-ftp         Install in $(FTPHOST):$(FTPHOME)$(FTPDESTDIR)'
	@echo 'make install-home        Install in $(HOMELIB)'
	@echo 'make install-local       Install in $(LOCALLIB)'
	@echo 'make uninstall           remove all installed files'
	@echo 'make uninstall-net       remove installed files from $(NETLIB)'
	@echo 'make uninstall-home      remove installed files from $(HOMELIB)'
	@echo 'make uninstall-local     remove installed files from $(LOCALLIB)'
	@echo 'make tar                 Make a tar.gz archive'
	@echo 'make shar                Make a shar archive'
	@echo 'make test                Run canned tests using "tq" and the "t" directory'
	@echo 'make help                This message'

test:	tq
	for testin in t/*.in ; do 				\
	    testout=t/`basename $$testin`.out ;			\
	    testref=t/`basename $$testin`.ref ;			\
	    testdif=t/`basename $$testin`.diff ;		\
	    $(MAKE) IN=$$testin OUT=$$testout perl-test ;	\
	    if [ -f $$testref ]; then				\
		$(MAKE) REF=$$testref OUT=$$testout 		\
			DIFF=$$testdif test-it ; 		\
	    else						\
		mv $$testout $$testref ;			\
	    fi ;						\
	done

perl-test:
	perl tq < $(IN) > $(OUT)

test-it:
	diff $(REF) $(OUT) > $(DIFF)
	@if [ -s $(DIFF) ]; then			\
	    echo "There are differences" ; 		\
	else						\
	    rm -f $(DIFF) $(OUT) ;			\
	fi

install:	$(DEFAULT)

install-all:	install-local install-home install-net

install-local:
	@$(MAKE) LIB='$(LOCALLIB)' 		\
		MAN='$(LOCALMAN)' 		\
		INSTALL_VER=$(INSTALL_VER) 	\
	    install-version

install-net:	
	@$(MAKE) LIB='$(NETLIB)'		\
		MAN='$(NETMAN)'			\
		INSTALL_VER=$(INSTALL_VER) 	\
	    install-version

install-home:
	@$(MAKE) LIB='$(HOMELIB)' 		\
		MAN='$(HOMEMAN)' 		\
		INSTALL_VER=$(INSTALL_VER) 	\
	    install-version

install-version:
	@if [ "$(INSTALL_VER)" != yes ]; then		\
	    $(MAKE)	MODULE_VER='$(MODULE)' 		\
			MANPAGE_VER='$(MANPAGE)'	\
			LIB='$(LIB)'			\
			MAN='$(MAN)'			\
		install-module install-man ;		\
	else						\
	    $(MAKE) version ;				\
	    $(MAKE) 	LIB='$(LIB)'			\
			MAN='$(MAN)'			\
			VERSION=`cat .version`		\
		install-module install-man ;		\
	fi

install-module:	$(MODULE_VER)

$(MODULE_VER):	$(MOD_NAME).pm
	@rm -f $@
	cp $(MOD_NAME).pm $@
	@if [ "$(MODULE_VER)" != "$(MODULE)" ]; then	\
	    $(MAKE) SRC='$(MODULE_VER)' 		\
	    	    LINK='$(MODULE)' 			\
		link ;					\
	fi

link:
	@rm -f $(LINK)
	ln $(SRC) $(LINK)

version:	.version
.version:	$(MOD_NAME).pm
	@rm -f $@
	awk '/[$$]Id[:]/{print $$4}' $(MOD_NAME).pm > $@

install-man:
	@rm -f $(MANPAGE_VER)
	$(POD2MAN) $(MOD_NAME).pm > $(MANPAGE_VER)
	@if [ "$(MANPAGE_VER)" != "$(MANPAGE)" ]; then	\
	    $(MAKE) SRC='$(MANPAGE_VER)' 		\
	    	    LINK='$(MANPAGE)' 			\
		link ;					\
	fi

$(LIB) $(LIB)/$(CLASS) $(MAN):
	mkdir -p $@

INSTALLED_FILES = $(MODULE_VER) $(MODULE) $(MANPAGE_VER) $(MANPAGE) 

uninstall:	uninstall-net uninstall-home uninstall-local

uninstall-net:
	@$(MAKE) LIB=$(NETLIB) MAN=$(NETMAN) uninstall-it
uninstall-home:
	@$(MAKE) LIB=$(HOMELIB) MAN=$(HOMEMAN) uninstall-it
uninstall-local:
	@$(MAKE) LIB=$(LOCALLIB) MAN=$(LOCALMAN) uninstall-it

uninstall-it:
	@for file in $(INSTALLED_FILES) ; do	\
	  if [ -f $$file ]; then		\
	    $(MAKE) FILE=$$file remove-it ;	\
	  fi ;					\
	done

remove-it:
	rm -f $(FILE)

# 	Archive creation stuff
#
#  MAKE_ARCHIVE invokes another 'make' at the directory level above the
#  current one, with the variables FILES, DIR, and ARCHIVE set
#  appropriately.

MAKE_ARCHIVE = 	cwd=`pwd` ;			\
		cd .. ; 			\
		dir=`basename $$cwd` ;		\
		files=`echo "$(SHARFILES)" |	\
		       tr ' ' '\12' |		\
		       sed -e "s=^=$$dir/=" |	\
		       tr '\12' ' ' ` ;		\
		$(MAKE) -f $$dir/Makefile	\
			FILES="$$files"		\
			DIR=$$dir		\
			ARCHIVE=$(ARCHIVE)

tar:			version
	@$(MAKE) VERSION="`cat .version`" tar-version

shar:			version
	@$(MAKE) VERSION="`cat .version`" shar-version

shar-version: 		$(ARCHIVE).shar
tar-version: 		$(ARCHIVE).tar.gz

$(ARCHIVE).tar.gz:	$(SHARFILES)
	@$(MAKE_ARCHIVE) make-tar
	@rm -f $@
	gzip $(ARCHIVE).tar

$(ARCHIVE).shar:	$(SHARFILES)
	@$(MAKE_ARCHIVE) make-shar

clean:
	rm -f *.tar.gz *.shar .version

make-tar:	$(FILES)
	@rm -f $(DIR)/$(ARCHIVE).tar
	tar cvf $(DIR)/$(ARCHIVE).tar $(FILES)

make-shar:	$(FILES)
	@rm -f $(DIR)/$(ARCHIVE).shar
	shar $(FILES) > $(DIR)/$(ARCHIVE).shar

install-ftp: shar tar
	$(MAKE) VERSION=`cat .version` install-ftp-version

install-ftp-version: $(ARCHIVE).shar $(ARCHIVE).tar.gz
	rcp $(ARCHIVE).shar $(ARCHIVE).tar.gz $(FTPHOST):$(FTPHOME)$(FTPDESTDIR)
