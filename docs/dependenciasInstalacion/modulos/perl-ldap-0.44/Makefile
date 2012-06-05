# This Makefile is for the Net::LDAP extension to perl.
#
# It was generated automatically by MakeMaker version
# 6.62 (Revision: 66200) from the contents of
# Makefile.PL. Don't edit this file, edit Makefile.PL instead.
#
#       ANY CHANGES MADE HERE WILL BE LOST!
#
#   MakeMaker ARGV: (q[INSTALL_BASE=/home/einar/meran/intranet/modules/externos])
#

#   MakeMaker Parameters:

#     ABSTRACT => q[LDAP client library]
#     AUTHOR => [q[Graham Barr <gbarr@cpan.org>]]
#     BUILD_REQUIRES => { ExtUtils::MakeMaker=>q[6.42] }
#     CONFIGURE_REQUIRES => {  }
#     DIR => []
#     DISTNAME => q[perl-ldap]
#     LICENSE => q[perl]
#     MIN_PERL_VERSION => q[5.008]
#     NAME => q[Net::LDAP]
#     NO_META => q[1]
#     PREREQ_PM => { ExtUtils::MakeMaker=>q[6.42], Convert::ASN1=>q[0.07] }
#     VERSION => q[0.44]
#     dist => {  }
#     realclean => { FILES=>q[MYMETA.yml] }
#     test => { TESTS=>q[t/00ldif-entry.t t/01canon_dn.t t/02filter.t t/03schema.t t/04refloop.t t/05dsml.t t/06constant.t t/50populate.t t/51search.t t/52modify.t t/53schema.t t/54dse.t t/55ssl.t t/56ipc.t t/57url.t t/58lwp.t t/70sortctrl.t] }

# --- MakeMaker post_initialize section:


# --- MakeMaker const_config section:

# These definitions are from config.sh (via /usr/lib/perl/5.10/Config.pm).
# They may have been overridden via Makefile.PL or on the command line.
AR = ar
CC = cc
CCCDLFLAGS = -fPIC
CCDLFLAGS = -Wl,-E
DLEXT = so
DLSRC = dl_dlopen.xs
EXE_EXT = 
FULL_AR = /usr/bin/ar
LD = cc
LDDLFLAGS = -shared -O2 -g -L/usr/local/lib -fstack-protector
LDFLAGS =  -fstack-protector -L/usr/local/lib
LIBC = /lib/libc-2.11.2.so
LIB_EXT = .a
OBJ_EXT = .o
OSNAME = linux
OSVERS = 2.6.32-5-686
RANLIB = :
SITELIBEXP = /usr/local/share/perl/5.10.1
SITEARCHEXP = /usr/local/lib/perl/5.10.1
SO = so
VENDORARCHEXP = /usr/lib/perl5
VENDORLIBEXP = /usr/share/perl5


# --- MakeMaker constants section:
AR_STATIC_ARGS = cr
DIRFILESEP = /
DFSEP = $(DIRFILESEP)
NAME = Net::LDAP
NAME_SYM = Net_LDAP
VERSION = 0.44
VERSION_MACRO = VERSION
VERSION_SYM = 0_44
DEFINE_VERSION = -D$(VERSION_MACRO)=\"$(VERSION)\"
XS_VERSION = 0.44
XS_VERSION_MACRO = XS_VERSION
XS_DEFINE_VERSION = -D$(XS_VERSION_MACRO)=\"$(XS_VERSION)\"
INST_ARCHLIB = blib/arch
INST_SCRIPT = blib/script
INST_BIN = blib/bin
INST_LIB = blib/lib
INST_MAN1DIR = blib/man1
INST_MAN3DIR = blib/man3
MAN1EXT = 1p
MAN3EXT = 3pm
INSTALLDIRS = site
INSTALL_BASE = /home/einar/meran/intranet/modules/externos
DESTDIR = 
PREFIX = $(INSTALL_BASE)
INSTALLPRIVLIB = $(INSTALL_BASE)/lib/perl5
DESTINSTALLPRIVLIB = $(DESTDIR)$(INSTALLPRIVLIB)
INSTALLSITELIB = $(INSTALL_BASE)/lib/perl5
DESTINSTALLSITELIB = $(DESTDIR)$(INSTALLSITELIB)
INSTALLVENDORLIB = $(INSTALL_BASE)/lib/perl5
DESTINSTALLVENDORLIB = $(DESTDIR)$(INSTALLVENDORLIB)
INSTALLARCHLIB = $(INSTALL_BASE)/lib/perl5/i486-linux-gnu-thread-multi
DESTINSTALLARCHLIB = $(DESTDIR)$(INSTALLARCHLIB)
INSTALLSITEARCH = $(INSTALL_BASE)/lib/perl5/i486-linux-gnu-thread-multi
DESTINSTALLSITEARCH = $(DESTDIR)$(INSTALLSITEARCH)
INSTALLVENDORARCH = $(INSTALL_BASE)/lib/perl5/i486-linux-gnu-thread-multi
DESTINSTALLVENDORARCH = $(DESTDIR)$(INSTALLVENDORARCH)
INSTALLBIN = $(INSTALL_BASE)/bin
DESTINSTALLBIN = $(DESTDIR)$(INSTALLBIN)
INSTALLSITEBIN = $(INSTALL_BASE)/bin
DESTINSTALLSITEBIN = $(DESTDIR)$(INSTALLSITEBIN)
INSTALLVENDORBIN = $(INSTALL_BASE)/bin
DESTINSTALLVENDORBIN = $(DESTDIR)$(INSTALLVENDORBIN)
INSTALLSCRIPT = $(INSTALL_BASE)/bin
DESTINSTALLSCRIPT = $(DESTDIR)$(INSTALLSCRIPT)
INSTALLSITESCRIPT = $(INSTALL_BASE)/bin
DESTINSTALLSITESCRIPT = $(DESTDIR)$(INSTALLSITESCRIPT)
INSTALLVENDORSCRIPT = $(INSTALL_BASE)/bin
DESTINSTALLVENDORSCRIPT = $(DESTDIR)$(INSTALLVENDORSCRIPT)
INSTALLMAN1DIR = $(INSTALL_BASE)/man/man1
DESTINSTALLMAN1DIR = $(DESTDIR)$(INSTALLMAN1DIR)
INSTALLSITEMAN1DIR = $(INSTALL_BASE)/man/man1
DESTINSTALLSITEMAN1DIR = $(DESTDIR)$(INSTALLSITEMAN1DIR)
INSTALLVENDORMAN1DIR = $(INSTALL_BASE)/man/man1
DESTINSTALLVENDORMAN1DIR = $(DESTDIR)$(INSTALLVENDORMAN1DIR)
INSTALLMAN3DIR = $(INSTALL_BASE)/man/man3
DESTINSTALLMAN3DIR = $(DESTDIR)$(INSTALLMAN3DIR)
INSTALLSITEMAN3DIR = $(INSTALL_BASE)/man/man3
DESTINSTALLSITEMAN3DIR = $(DESTDIR)$(INSTALLSITEMAN3DIR)
INSTALLVENDORMAN3DIR = $(INSTALL_BASE)/man/man3
DESTINSTALLVENDORMAN3DIR = $(DESTDIR)$(INSTALLVENDORMAN3DIR)
PERL_LIB =
PERL_ARCHLIB = /usr/lib/perl/5.10
LIBPERL_A = libperl.a
FIRST_MAKEFILE = Makefile
MAKEFILE_OLD = Makefile.old
MAKE_APERL_FILE = Makefile.aperl
PERLMAINCC = $(CC)
PERL_INC = /usr/lib/perl/5.10/CORE
PERL = /usr/bin/perl "-Iinc"
FULLPERL = /usr/bin/perl "-Iinc"
ABSPERL = $(PERL)
PERLRUN = $(PERL)
FULLPERLRUN = $(FULLPERL)
ABSPERLRUN = $(ABSPERL)
PERLRUNINST = $(PERLRUN) "-I$(INST_ARCHLIB)" "-Iinc" "-I$(INST_LIB)"
FULLPERLRUNINST = $(FULLPERLRUN) "-I$(INST_ARCHLIB)" "-Iinc" "-I$(INST_LIB)"
ABSPERLRUNINST = $(ABSPERLRUN) "-I$(INST_ARCHLIB)" "-Iinc" "-I$(INST_LIB)"
PERL_CORE = 0
PERM_DIR = 755
PERM_RW = 644
PERM_RWX = 755

MAKEMAKER   = /usr/local/share/perl/5.10.1/ExtUtils/MakeMaker.pm
MM_VERSION  = 6.62
MM_REVISION = 66200

# FULLEXT = Pathname for extension directory (eg Foo/Bar/Oracle).
# BASEEXT = Basename part of FULLEXT. May be just equal FULLEXT. (eg Oracle)
# PARENT_NAME = NAME without BASEEXT and no trailing :: (eg Foo::Bar)
# DLBASE  = Basename part of dynamic library. May be just equal BASEEXT.
MAKE = make
FULLEXT = Net/LDAP
BASEEXT = LDAP
PARENT_NAME = Net
DLBASE = $(BASEEXT)
VERSION_FROM = 
OBJECT = 
LDFROM = $(OBJECT)
LINKTYPE = dynamic
BOOTDEP = 

# Handy lists of source code files:
XS_FILES = 
C_FILES  = 
O_FILES  = 
H_FILES  = 
MAN1PODS = 
MAN3PODS = lib/Bundle/Net/LDAP.pm \
	lib/Net/LDAP.pod \
	lib/Net/LDAP/Constant.pm \
	lib/Net/LDAP/Control.pm \
	lib/Net/LDAP/Control/Assertion.pm \
	lib/Net/LDAP/Control/EntryChange.pm \
	lib/Net/LDAP/Control/ManageDsaIT.pm \
	lib/Net/LDAP/Control/MatchedValues.pm \
	lib/Net/LDAP/Control/Paged.pm \
	lib/Net/LDAP/Control/PasswordPolicy.pm \
	lib/Net/LDAP/Control/PersistentSearch.pm \
	lib/Net/LDAP/Control/PostRead.pm \
	lib/Net/LDAP/Control/PreRead.pm \
	lib/Net/LDAP/Control/ProxyAuth.pm \
	lib/Net/LDAP/Control/Sort.pm \
	lib/Net/LDAP/Control/SortResult.pm \
	lib/Net/LDAP/Control/SyncDone.pm \
	lib/Net/LDAP/Control/SyncRequest.pm \
	lib/Net/LDAP/Control/SyncState.pm \
	lib/Net/LDAP/Control/VLV.pm \
	lib/Net/LDAP/Control/VLVResponse.pm \
	lib/Net/LDAP/DSML.pm \
	lib/Net/LDAP/Entry.pod \
	lib/Net/LDAP/Examples.pod \
	lib/Net/LDAP/Extension/Cancel.pm \
	lib/Net/LDAP/Extension/Refresh.pm \
	lib/Net/LDAP/Extension/SetPassword.pm \
	lib/Net/LDAP/Extension/WhoAmI.pm \
	lib/Net/LDAP/Extra.pm \
	lib/Net/LDAP/FAQ.pod \
	lib/Net/LDAP/Filter.pod \
	lib/Net/LDAP/FilterMatch.pm \
	lib/Net/LDAP/Intermediate.pm \
	lib/Net/LDAP/Intermediate/SyncInfo.pm \
	lib/Net/LDAP/LDIF.pod \
	lib/Net/LDAP/Message.pod \
	lib/Net/LDAP/RFC.pod \
	lib/Net/LDAP/Reference.pod \
	lib/Net/LDAP/RootDSE.pm \
	lib/Net/LDAP/Schema.pod \
	lib/Net/LDAP/Search.pod \
	lib/Net/LDAP/Security.pod \
	lib/Net/LDAP/Util.pm \
	lib/Net/LDAPI.pm \
	lib/Net/LDAPS.pm

# Where is the Config information that we are using/depend on
CONFIGDEP = $(PERL_ARCHLIB)$(DFSEP)Config.pm $(PERL_INC)$(DFSEP)config.h

# Where to build things
INST_LIBDIR      = $(INST_LIB)/Net
INST_ARCHLIBDIR  = $(INST_ARCHLIB)/Net

INST_AUTODIR     = $(INST_LIB)/auto/$(FULLEXT)
INST_ARCHAUTODIR = $(INST_ARCHLIB)/auto/$(FULLEXT)

INST_STATIC      = 
INST_DYNAMIC     = 
INST_BOOT        = 

# Extra linker info
EXPORT_LIST        = 
PERL_ARCHIVE       = 
PERL_ARCHIVE_AFTER = 


TO_INST_PM = lib/Bundle/Net/LDAP.pm \
	lib/LWP/Protocol/ldap.pm \
	lib/LWP/Protocol/ldaps.pm \
	lib/Net/LDAP.pm \
	lib/Net/LDAP.pod \
	lib/Net/LDAP/ASN.pm \
	lib/Net/LDAP/Bind.pm \
	lib/Net/LDAP/Constant.pm \
	lib/Net/LDAP/Control.pm \
	lib/Net/LDAP/Control/Assertion.pm \
	lib/Net/LDAP/Control/EntryChange.pm \
	lib/Net/LDAP/Control/ManageDsaIT.pm \
	lib/Net/LDAP/Control/MatchedValues.pm \
	lib/Net/LDAP/Control/Paged.pm \
	lib/Net/LDAP/Control/PasswordPolicy.pm \
	lib/Net/LDAP/Control/PersistentSearch.pm \
	lib/Net/LDAP/Control/PostRead.pm \
	lib/Net/LDAP/Control/PreRead.pm \
	lib/Net/LDAP/Control/ProxyAuth.pm \
	lib/Net/LDAP/Control/Sort.pm \
	lib/Net/LDAP/Control/SortResult.pm \
	lib/Net/LDAP/Control/SyncDone.pm \
	lib/Net/LDAP/Control/SyncRequest.pm \
	lib/Net/LDAP/Control/SyncState.pm \
	lib/Net/LDAP/Control/VLV.pm \
	lib/Net/LDAP/Control/VLVResponse.pm \
	lib/Net/LDAP/DSML.pm \
	lib/Net/LDAP/Entry.pm \
	lib/Net/LDAP/Entry.pod \
	lib/Net/LDAP/Examples.pod \
	lib/Net/LDAP/Extension.pm \
	lib/Net/LDAP/Extension/Cancel.pm \
	lib/Net/LDAP/Extension/Refresh.pm \
	lib/Net/LDAP/Extension/SetPassword.pm \
	lib/Net/LDAP/Extension/WhoAmI.pm \
	lib/Net/LDAP/Extra.pm \
	lib/Net/LDAP/FAQ.pod \
	lib/Net/LDAP/Filter.pm \
	lib/Net/LDAP/Filter.pod \
	lib/Net/LDAP/FilterMatch.pm \
	lib/Net/LDAP/Intermediate.pm \
	lib/Net/LDAP/Intermediate/SyncInfo.pm \
	lib/Net/LDAP/LDIF.pm \
	lib/Net/LDAP/LDIF.pod \
	lib/Net/LDAP/Message.pm \
	lib/Net/LDAP/Message.pod \
	lib/Net/LDAP/RFC.pod \
	lib/Net/LDAP/Reference.pod \
	lib/Net/LDAP/RootDSE.pm \
	lib/Net/LDAP/Schema.pm \
	lib/Net/LDAP/Schema.pod \
	lib/Net/LDAP/Search.pm \
	lib/Net/LDAP/Search.pod \
	lib/Net/LDAP/Security.pod \
	lib/Net/LDAP/Util.pm \
	lib/Net/LDAPI.pm \
	lib/Net/LDAPS.pm

PM_TO_BLIB = lib/Net/LDAP/Control/PostRead.pm \
	blib/lib/Net/LDAP/Control/PostRead.pm \
	lib/Net/LDAP/FilterMatch.pm \
	blib/lib/Net/LDAP/FilterMatch.pm \
	lib/Net/LDAP/Entry.pod \
	blib/lib/Net/LDAP/Entry.pod \
	lib/Net/LDAP/Control/SyncDone.pm \
	blib/lib/Net/LDAP/Control/SyncDone.pm \
	lib/Net/LDAP/Message.pod \
	blib/lib/Net/LDAP/Message.pod \
	lib/Net/LDAP/Util.pm \
	blib/lib/Net/LDAP/Util.pm \
	lib/Net/LDAP/Extension/WhoAmI.pm \
	blib/lib/Net/LDAP/Extension/WhoAmI.pm \
	lib/Net/LDAP/DSML.pm \
	blib/lib/Net/LDAP/DSML.pm \
	lib/Net/LDAP/LDIF.pm \
	blib/lib/Net/LDAP/LDIF.pm \
	lib/Net/LDAP/Extension/Cancel.pm \
	blib/lib/Net/LDAP/Extension/Cancel.pm \
	lib/Net/LDAP/LDIF.pod \
	blib/lib/Net/LDAP/LDIF.pod \
	lib/Net/LDAP/Filter.pod \
	blib/lib/Net/LDAP/Filter.pod \
	lib/Net/LDAP/Security.pod \
	blib/lib/Net/LDAP/Security.pod \
	lib/Net/LDAP/Control/VLV.pm \
	blib/lib/Net/LDAP/Control/VLV.pm \
	lib/Net/LDAP/Control/SortResult.pm \
	blib/lib/Net/LDAP/Control/SortResult.pm \
	lib/Net/LDAP/Control/ManageDsaIT.pm \
	blib/lib/Net/LDAP/Control/ManageDsaIT.pm \
	lib/Net/LDAP/Control/ProxyAuth.pm \
	blib/lib/Net/LDAP/Control/ProxyAuth.pm \
	lib/Net/LDAPI.pm \
	blib/lib/Net/LDAPI.pm \
	lib/LWP/Protocol/ldaps.pm \
	blib/lib/LWP/Protocol/ldaps.pm \
	lib/Net/LDAP/Control/Sort.pm \
	blib/lib/Net/LDAP/Control/Sort.pm \
	lib/Net/LDAPS.pm \
	blib/lib/Net/LDAPS.pm \
	lib/Net/LDAP/Control/SyncRequest.pm \
	blib/lib/Net/LDAP/Control/SyncRequest.pm \
	lib/Net/LDAP/Extension/Refresh.pm \
	blib/lib/Net/LDAP/Extension/Refresh.pm \
	lib/Net/LDAP/Message.pm \
	blib/lib/Net/LDAP/Message.pm \
	lib/Net/LDAP/Search.pm \
	blib/lib/Net/LDAP/Search.pm \
	lib/Net/LDAP/RootDSE.pm \
	blib/lib/Net/LDAP/RootDSE.pm \
	lib/Net/LDAP/FAQ.pod \
	blib/lib/Net/LDAP/FAQ.pod \
	lib/Net/LDAP/ASN.pm \
	blib/lib/Net/LDAP/ASN.pm \
	lib/Bundle/Net/LDAP.pm \
	blib/lib/Bundle/Net/LDAP.pm \
	lib/LWP/Protocol/ldap.pm \
	blib/lib/LWP/Protocol/ldap.pm \
	lib/Net/LDAP/Extra.pm \
	blib/lib/Net/LDAP/Extra.pm \
	lib/Net/LDAP/Control.pm \
	blib/lib/Net/LDAP/Control.pm \
	lib/Net/LDAP/Entry.pm \
	blib/lib/Net/LDAP/Entry.pm \
	lib/Net/LDAP/Control/VLVResponse.pm \
	blib/lib/Net/LDAP/Control/VLVResponse.pm \
	lib/Net/LDAP/Control/PersistentSearch.pm \
	blib/lib/Net/LDAP/Control/PersistentSearch.pm \
	lib/Net/LDAP/Schema.pm \
	blib/lib/Net/LDAP/Schema.pm \
	lib/Net/LDAP/Bind.pm \
	blib/lib/Net/LDAP/Bind.pm \
	lib/Net/LDAP/Control/PreRead.pm \
	blib/lib/Net/LDAP/Control/PreRead.pm \
	lib/Net/LDAP/Control/Paged.pm \
	blib/lib/Net/LDAP/Control/Paged.pm \
	lib/Net/LDAP/Filter.pm \
	blib/lib/Net/LDAP/Filter.pm \
	lib/Net/LDAP/Control/PasswordPolicy.pm \
	blib/lib/Net/LDAP/Control/PasswordPolicy.pm \
	lib/Net/LDAP/Control/EntryChange.pm \
	blib/lib/Net/LDAP/Control/EntryChange.pm \
	lib/Net/LDAP/Intermediate.pm \
	blib/lib/Net/LDAP/Intermediate.pm \
	lib/Net/LDAP/Schema.pod \
	blib/lib/Net/LDAP/Schema.pod \
	lib/Net/LDAP/Examples.pod \
	blib/lib/Net/LDAP/Examples.pod \
	lib/Net/LDAP/RFC.pod \
	blib/lib/Net/LDAP/RFC.pod \
	lib/Net/LDAP/Extension/SetPassword.pm \
	blib/lib/Net/LDAP/Extension/SetPassword.pm \
	lib/Net/LDAP/Intermediate/SyncInfo.pm \
	blib/lib/Net/LDAP/Intermediate/SyncInfo.pm \
	lib/Net/LDAP.pm \
	blib/lib/Net/LDAP.pm \
	lib/Net/LDAP/Control/SyncState.pm \
	blib/lib/Net/LDAP/Control/SyncState.pm \
	lib/Net/LDAP/Extension.pm \
	blib/lib/Net/LDAP/Extension.pm \
	lib/Net/LDAP/Control/MatchedValues.pm \
	blib/lib/Net/LDAP/Control/MatchedValues.pm \
	lib/Net/LDAP/Reference.pod \
	blib/lib/Net/LDAP/Reference.pod \
	lib/Net/LDAP.pod \
	blib/lib/Net/LDAP.pod \
	lib/Net/LDAP/Constant.pm \
	blib/lib/Net/LDAP/Constant.pm \
	lib/Net/LDAP/Search.pod \
	blib/lib/Net/LDAP/Search.pod \
	lib/Net/LDAP/Control/Assertion.pm \
	blib/lib/Net/LDAP/Control/Assertion.pm


# --- MakeMaker platform_constants section:
MM_Unix_VERSION = 6.62
PERL_MALLOC_DEF = -DPERL_EXTMALLOC_DEF -Dmalloc=Perl_malloc -Dfree=Perl_mfree -Drealloc=Perl_realloc -Dcalloc=Perl_calloc


# --- MakeMaker tool_autosplit section:
# Usage: $(AUTOSPLITFILE) FileToSplit AutoDirToSplitInto
AUTOSPLITFILE = $(ABSPERLRUN)  -e 'use AutoSplit;  autosplit($$ARGV[0], $$ARGV[1], 0, 1, 1)' --



# --- MakeMaker tool_xsubpp section:


# --- MakeMaker tools_other section:
SHELL = /bin/sh
CHMOD = chmod
CP = cp
MV = mv
NOOP = $(TRUE)
NOECHO = @
RM_F = rm -f
RM_RF = rm -rf
TEST_F = test -f
TOUCH = touch
UMASK_NULL = umask 0
DEV_NULL = > /dev/null 2>&1
MKPATH = $(ABSPERLRUN) -MExtUtils::Command -e 'mkpath' --
EQUALIZE_TIMESTAMP = $(ABSPERLRUN) -MExtUtils::Command -e 'eqtime' --
FALSE = false
TRUE = true
ECHO = echo
ECHO_N = echo -n
UNINST = 0
VERBINST = 0
MOD_INSTALL = $(ABSPERLRUN) -MExtUtils::Install -e 'install([ from_to => {@ARGV}, verbose => '\''$(VERBINST)'\'', uninstall_shadows => '\''$(UNINST)'\'', dir_mode => '\''$(PERM_DIR)'\'' ]);' --
DOC_INSTALL = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'perllocal_install' --
UNINSTALL = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'uninstall' --
WARN_IF_OLD_PACKLIST = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'warn_if_old_packlist' --
MACROSTART = 
MACROEND = 
USEMAKEFILE = -f
FIXIN = $(ABSPERLRUN) -MExtUtils::MY -e 'MY->fixin(shift)' --


# --- MakeMaker makemakerdflt section:
makemakerdflt : all
	$(NOECHO) $(NOOP)


# --- MakeMaker dist section:
TAR = tar
TARFLAGS = cvf
ZIP = zip
ZIPFLAGS = -r
COMPRESS = gzip --best
SUFFIX = .gz
SHAR = shar
PREOP = $(NOECHO) $(NOOP)
POSTOP = $(NOECHO) $(NOOP)
TO_UNIX = $(NOECHO) $(NOOP)
CI = ci -u
RCS_LABEL = rcs -Nv$(VERSION_SYM): -q
DIST_CP = best
DIST_DEFAULT = tardist
DISTNAME = perl-ldap
DISTVNAME = perl-ldap-0.44


# --- MakeMaker macro section:


# --- MakeMaker depend section:


# --- MakeMaker cflags section:


# --- MakeMaker const_loadlibs section:


# --- MakeMaker const_cccmd section:


# --- MakeMaker post_constants section:


# --- MakeMaker pasthru section:

PASTHRU = LIBPERL_A="$(LIBPERL_A)"\
	LINKTYPE="$(LINKTYPE)"\
	PREFIX="$(PREFIX)"\
	INSTALL_BASE="$(INSTALL_BASE)"


# --- MakeMaker special_targets section:
.SUFFIXES : .xs .c .C .cpp .i .s .cxx .cc $(OBJ_EXT)

.PHONY: all config static dynamic test linkext manifest blibdirs clean realclean disttest distdir



# --- MakeMaker c_o section:


# --- MakeMaker xs_c section:


# --- MakeMaker xs_o section:


# --- MakeMaker top_targets section:
all :: pure_all manifypods
	$(NOECHO) $(NOOP)


pure_all :: config pm_to_blib subdirs linkext
	$(NOECHO) $(NOOP)

subdirs :: $(MYEXTLIB)
	$(NOECHO) $(NOOP)

config :: $(FIRST_MAKEFILE) blibdirs
	$(NOECHO) $(NOOP)

help :
	perldoc ExtUtils::MakeMaker


# --- MakeMaker blibdirs section:
blibdirs : $(INST_LIBDIR)$(DFSEP).exists $(INST_ARCHLIB)$(DFSEP).exists $(INST_AUTODIR)$(DFSEP).exists $(INST_ARCHAUTODIR)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists $(INST_SCRIPT)$(DFSEP).exists $(INST_MAN1DIR)$(DFSEP).exists $(INST_MAN3DIR)$(DFSEP).exists
	$(NOECHO) $(NOOP)

# Backwards compat with 6.18 through 6.25
blibdirs.ts : blibdirs
	$(NOECHO) $(NOOP)

$(INST_LIBDIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_LIBDIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_LIBDIR)
	$(NOECHO) $(TOUCH) $(INST_LIBDIR)$(DFSEP).exists

$(INST_ARCHLIB)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_ARCHLIB)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_ARCHLIB)
	$(NOECHO) $(TOUCH) $(INST_ARCHLIB)$(DFSEP).exists

$(INST_AUTODIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_AUTODIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_AUTODIR)
	$(NOECHO) $(TOUCH) $(INST_AUTODIR)$(DFSEP).exists

$(INST_ARCHAUTODIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_ARCHAUTODIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_ARCHAUTODIR)
	$(NOECHO) $(TOUCH) $(INST_ARCHAUTODIR)$(DFSEP).exists

$(INST_BIN)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_BIN)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_BIN)
	$(NOECHO) $(TOUCH) $(INST_BIN)$(DFSEP).exists

$(INST_SCRIPT)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_SCRIPT)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_SCRIPT)
	$(NOECHO) $(TOUCH) $(INST_SCRIPT)$(DFSEP).exists

$(INST_MAN1DIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_MAN1DIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_MAN1DIR)
	$(NOECHO) $(TOUCH) $(INST_MAN1DIR)$(DFSEP).exists

$(INST_MAN3DIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_MAN3DIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_MAN3DIR)
	$(NOECHO) $(TOUCH) $(INST_MAN3DIR)$(DFSEP).exists



# --- MakeMaker linkext section:

linkext :: $(LINKTYPE)
	$(NOECHO) $(NOOP)


# --- MakeMaker dlsyms section:


# --- MakeMaker dynamic section:

dynamic :: $(FIRST_MAKEFILE) $(INST_DYNAMIC) $(INST_BOOT)
	$(NOECHO) $(NOOP)


# --- MakeMaker dynamic_bs section:

BOOTSTRAP =


# --- MakeMaker dynamic_lib section:


# --- MakeMaker static section:

## $(INST_PM) has been moved to the all: target.
## It remains here for awhile to allow for old usage: "make static"
static :: $(FIRST_MAKEFILE) $(INST_STATIC)
	$(NOECHO) $(NOOP)


# --- MakeMaker static_lib section:


# --- MakeMaker manifypods section:

POD2MAN_EXE = $(PERLRUN) "-MExtUtils::Command::MM" -e pod2man "--"
POD2MAN = $(POD2MAN_EXE)


manifypods : pure_all  \
	lib/Net/LDAP/Control/PostRead.pm \
	lib/Net/LDAP/FilterMatch.pm \
	lib/Net/LDAP/Entry.pod \
	lib/Net/LDAP/Control/SyncDone.pm \
	lib/Net/LDAP/Message.pod \
	lib/Net/LDAP/Util.pm \
	lib/Net/LDAP/Extension/WhoAmI.pm \
	lib/Net/LDAP/DSML.pm \
	lib/Net/LDAP/Extension/Cancel.pm \
	lib/Net/LDAP/LDIF.pod \
	lib/Net/LDAP/Filter.pod \
	lib/Net/LDAP/Security.pod \
	lib/Net/LDAP/Control/VLV.pm \
	lib/Net/LDAP/Control/SortResult.pm \
	lib/Net/LDAP/Control/ManageDsaIT.pm \
	lib/Net/LDAP/Control/ProxyAuth.pm \
	lib/Net/LDAPI.pm \
	lib/Net/LDAP/Control/Sort.pm \
	lib/Net/LDAPS.pm \
	lib/Net/LDAP/Control/SyncRequest.pm \
	lib/Net/LDAP/Extension/Refresh.pm \
	lib/Net/LDAP/RootDSE.pm \
	lib/Net/LDAP/FAQ.pod \
	lib/Bundle/Net/LDAP.pm \
	lib/Net/LDAP/Extra.pm \
	lib/Net/LDAP/Control.pm \
	lib/Net/LDAP/Control/VLVResponse.pm \
	lib/Net/LDAP/Control/PersistentSearch.pm \
	lib/Net/LDAP/Control/PreRead.pm \
	lib/Net/LDAP/Control/Paged.pm \
	lib/Net/LDAP/Control/PasswordPolicy.pm \
	lib/Net/LDAP/Control/EntryChange.pm \
	lib/Net/LDAP/Intermediate.pm \
	lib/Net/LDAP/Schema.pod \
	lib/Net/LDAP/Examples.pod \
	lib/Net/LDAP/RFC.pod \
	lib/Net/LDAP/Extension/SetPassword.pm \
	lib/Net/LDAP/Intermediate/SyncInfo.pm \
	lib/Net/LDAP/Control/SyncState.pm \
	lib/Net/LDAP/Control/MatchedValues.pm \
	lib/Net/LDAP/Reference.pod \
	lib/Net/LDAP.pod \
	lib/Net/LDAP/Constant.pm \
	lib/Net/LDAP/Search.pod \
	lib/Net/LDAP/Control/Assertion.pm
	$(NOECHO) $(POD2MAN) --section=3 --perm_rw=$(PERM_RW) \
	  lib/Net/LDAP/Control/PostRead.pm $(INST_MAN3DIR)/Net::LDAP::Control::PostRead.$(MAN3EXT) \
	  lib/Net/LDAP/FilterMatch.pm $(INST_MAN3DIR)/Net::LDAP::FilterMatch.$(MAN3EXT) \
	  lib/Net/LDAP/Entry.pod $(INST_MAN3DIR)/Net::LDAP::Entry.$(MAN3EXT) \
	  lib/Net/LDAP/Control/SyncDone.pm $(INST_MAN3DIR)/Net::LDAP::Control::SyncDone.$(MAN3EXT) \
	  lib/Net/LDAP/Message.pod $(INST_MAN3DIR)/Net::LDAP::Message.$(MAN3EXT) \
	  lib/Net/LDAP/Util.pm $(INST_MAN3DIR)/Net::LDAP::Util.$(MAN3EXT) \
	  lib/Net/LDAP/Extension/WhoAmI.pm $(INST_MAN3DIR)/Net::LDAP::Extension::WhoAmI.$(MAN3EXT) \
	  lib/Net/LDAP/DSML.pm $(INST_MAN3DIR)/Net::LDAP::DSML.$(MAN3EXT) \
	  lib/Net/LDAP/Extension/Cancel.pm $(INST_MAN3DIR)/Net::LDAP::Extension::Cancel.$(MAN3EXT) \
	  lib/Net/LDAP/LDIF.pod $(INST_MAN3DIR)/Net::LDAP::LDIF.$(MAN3EXT) \
	  lib/Net/LDAP/Filter.pod $(INST_MAN3DIR)/Net::LDAP::Filter.$(MAN3EXT) \
	  lib/Net/LDAP/Security.pod $(INST_MAN3DIR)/Net::LDAP::Security.$(MAN3EXT) \
	  lib/Net/LDAP/Control/VLV.pm $(INST_MAN3DIR)/Net::LDAP::Control::VLV.$(MAN3EXT) \
	  lib/Net/LDAP/Control/SortResult.pm $(INST_MAN3DIR)/Net::LDAP::Control::SortResult.$(MAN3EXT) \
	  lib/Net/LDAP/Control/ManageDsaIT.pm $(INST_MAN3DIR)/Net::LDAP::Control::ManageDsaIT.$(MAN3EXT) \
	  lib/Net/LDAP/Control/ProxyAuth.pm $(INST_MAN3DIR)/Net::LDAP::Control::ProxyAuth.$(MAN3EXT) \
	  lib/Net/LDAPI.pm $(INST_MAN3DIR)/Net::LDAPI.$(MAN3EXT) \
	  lib/Net/LDAP/Control/Sort.pm $(INST_MAN3DIR)/Net::LDAP::Control::Sort.$(MAN3EXT) \
	  lib/Net/LDAPS.pm $(INST_MAN3DIR)/Net::LDAPS.$(MAN3EXT) \
	  lib/Net/LDAP/Control/SyncRequest.pm $(INST_MAN3DIR)/Net::LDAP::Control::SyncRequest.$(MAN3EXT) \
	  lib/Net/LDAP/Extension/Refresh.pm $(INST_MAN3DIR)/Net::LDAP::Extension::Refresh.$(MAN3EXT) \
	  lib/Net/LDAP/RootDSE.pm $(INST_MAN3DIR)/Net::LDAP::RootDSE.$(MAN3EXT) \
	  lib/Net/LDAP/FAQ.pod $(INST_MAN3DIR)/Net::LDAP::FAQ.$(MAN3EXT) \
	  lib/Bundle/Net/LDAP.pm $(INST_MAN3DIR)/Bundle::Net::LDAP.$(MAN3EXT) \
	  lib/Net/LDAP/Extra.pm $(INST_MAN3DIR)/Net::LDAP::Extra.$(MAN3EXT) \
	  lib/Net/LDAP/Control.pm $(INST_MAN3DIR)/Net::LDAP::Control.$(MAN3EXT) \
	  lib/Net/LDAP/Control/VLVResponse.pm $(INST_MAN3DIR)/Net::LDAP::Control::VLVResponse.$(MAN3EXT) \
	  lib/Net/LDAP/Control/PersistentSearch.pm $(INST_MAN3DIR)/Net::LDAP::Control::PersistentSearch.$(MAN3EXT) \
	  lib/Net/LDAP/Control/PreRead.pm $(INST_MAN3DIR)/Net::LDAP::Control::PreRead.$(MAN3EXT) \
	  lib/Net/LDAP/Control/Paged.pm $(INST_MAN3DIR)/Net::LDAP::Control::Paged.$(MAN3EXT) \
	  lib/Net/LDAP/Control/PasswordPolicy.pm $(INST_MAN3DIR)/Net::LDAP::Control::PasswordPolicy.$(MAN3EXT) \
	  lib/Net/LDAP/Control/EntryChange.pm $(INST_MAN3DIR)/Net::LDAP::Control::EntryChange.$(MAN3EXT) \
	  lib/Net/LDAP/Intermediate.pm $(INST_MAN3DIR)/Net::LDAP::Intermediate.$(MAN3EXT) 
	$(NOECHO) $(POD2MAN) --section=3 --perm_rw=$(PERM_RW) \
	  lib/Net/LDAP/Schema.pod $(INST_MAN3DIR)/Net::LDAP::Schema.$(MAN3EXT) \
	  lib/Net/LDAP/Examples.pod $(INST_MAN3DIR)/Net::LDAP::Examples.$(MAN3EXT) \
	  lib/Net/LDAP/RFC.pod $(INST_MAN3DIR)/Net::LDAP::RFC.$(MAN3EXT) \
	  lib/Net/LDAP/Extension/SetPassword.pm $(INST_MAN3DIR)/Net::LDAP::Extension::SetPassword.$(MAN3EXT) \
	  lib/Net/LDAP/Intermediate/SyncInfo.pm $(INST_MAN3DIR)/Net::LDAP::Intermediate::SyncInfo.$(MAN3EXT) \
	  lib/Net/LDAP/Control/SyncState.pm $(INST_MAN3DIR)/Net::LDAP::Control::SyncState.$(MAN3EXT) \
	  lib/Net/LDAP/Control/MatchedValues.pm $(INST_MAN3DIR)/Net::LDAP::Control::MatchedValues.$(MAN3EXT) \
	  lib/Net/LDAP/Reference.pod $(INST_MAN3DIR)/Net::LDAP::Reference.$(MAN3EXT) \
	  lib/Net/LDAP.pod $(INST_MAN3DIR)/Net::LDAP.$(MAN3EXT) \
	  lib/Net/LDAP/Constant.pm $(INST_MAN3DIR)/Net::LDAP::Constant.$(MAN3EXT) \
	  lib/Net/LDAP/Search.pod $(INST_MAN3DIR)/Net::LDAP::Search.$(MAN3EXT) \
	  lib/Net/LDAP/Control/Assertion.pm $(INST_MAN3DIR)/Net::LDAP::Control::Assertion.$(MAN3EXT) 




# --- MakeMaker processPL section:


# --- MakeMaker installbin section:


# --- MakeMaker subdirs section:

# none

# --- MakeMaker clean_subdirs section:
clean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker clean section:

# Delete temporary files but do not touch installed files. We don't delete
# the Makefile here so a later make realclean still has a makefile to use.

clean :: clean_subdirs
	- $(RM_F) \
	  *$(LIB_EXT) core \
	  core.[0-9] $(INST_ARCHAUTODIR)/extralibs.all \
	  core.[0-9][0-9] $(BASEEXT).bso \
	  pm_to_blib.ts MYMETA.json \
	  core.[0-9][0-9][0-9][0-9] MYMETA.yml \
	  $(BASEEXT).x $(BOOTSTRAP) \
	  perl$(EXE_EXT) tmon.out \
	  *$(OBJ_EXT) pm_to_blib \
	  $(INST_ARCHAUTODIR)/extralibs.ld blibdirs.ts \
	  core.[0-9][0-9][0-9][0-9][0-9] *perl.core \
	  core.*perl.*.? $(MAKE_APERL_FILE) \
	  $(BASEEXT).def perl \
	  core.[0-9][0-9][0-9] mon.out \
	  lib$(BASEEXT).def perlmain.c \
	  perl.exe so_locations \
	  $(BASEEXT).exp 
	- $(RM_RF) \
	  blib 
	- $(MV) $(FIRST_MAKEFILE) $(MAKEFILE_OLD) $(DEV_NULL)


# --- MakeMaker realclean_subdirs section:
realclean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker realclean section:
# Delete temporary files (via clean) and also delete dist files
realclean purge ::  clean realclean_subdirs
	- $(RM_F) \
	  $(MAKEFILE_OLD) $(FIRST_MAKEFILE) 
	- $(RM_RF) \
	  MYMETA.yml $(DISTVNAME) 


# --- MakeMaker metafile section:
metafile :
	$(NOECHO) $(NOOP)


# --- MakeMaker signature section:
signature :
	cpansign -s


# --- MakeMaker dist_basics section:
distclean :: realclean distcheck
	$(NOECHO) $(NOOP)

distcheck :
	$(PERLRUN) "-MExtUtils::Manifest=fullcheck" -e fullcheck

skipcheck :
	$(PERLRUN) "-MExtUtils::Manifest=skipcheck" -e skipcheck

manifest :
	$(PERLRUN) "-MExtUtils::Manifest=mkmanifest" -e mkmanifest

veryclean : realclean
	$(RM_F) *~ */*~ *.orig */*.orig *.bak */*.bak *.old */*.old 



# --- MakeMaker dist_core section:

dist : $(DIST_DEFAULT) $(FIRST_MAKEFILE)
	$(NOECHO) $(ABSPERLRUN) -l -e 'print '\''Warning: Makefile possibly out of date with $(VERSION_FROM)'\''' \
	  -e '    if -e '\''$(VERSION_FROM)'\'' and -M '\''$(VERSION_FROM)'\'' < -M '\''$(FIRST_MAKEFILE)'\'';' --

tardist : $(DISTVNAME).tar$(SUFFIX)
	$(NOECHO) $(NOOP)

uutardist : $(DISTVNAME).tar$(SUFFIX)
	uuencode $(DISTVNAME).tar$(SUFFIX) $(DISTVNAME).tar$(SUFFIX) > $(DISTVNAME).tar$(SUFFIX)_uu

$(DISTVNAME).tar$(SUFFIX) : distdir
	$(PREOP)
	$(TO_UNIX)
	$(TAR) $(TARFLAGS) $(DISTVNAME).tar $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(COMPRESS) $(DISTVNAME).tar
	$(POSTOP)

zipdist : $(DISTVNAME).zip
	$(NOECHO) $(NOOP)

$(DISTVNAME).zip : distdir
	$(PREOP)
	$(ZIP) $(ZIPFLAGS) $(DISTVNAME).zip $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(POSTOP)

shdist : distdir
	$(PREOP)
	$(SHAR) $(DISTVNAME) > $(DISTVNAME).shar
	$(RM_RF) $(DISTVNAME)
	$(POSTOP)


# --- MakeMaker distdir section:
create_distdir :
	$(RM_RF) $(DISTVNAME)
	$(PERLRUN) "-MExtUtils::Manifest=manicopy,maniread" \
		-e "manicopy(maniread(),'$(DISTVNAME)', '$(DIST_CP)');"

distdir : create_distdir  
	$(NOECHO) $(NOOP)



# --- MakeMaker dist_test section:
disttest : distdir
	cd $(DISTVNAME) && $(ABSPERLRUN) Makefile.PL "INSTALL_BASE=/home/einar/meran/intranet/modules/externos"
	cd $(DISTVNAME) && $(MAKE) $(PASTHRU)
	cd $(DISTVNAME) && $(MAKE) test $(PASTHRU)



# --- MakeMaker dist_ci section:

ci :
	$(PERLRUN) "-MExtUtils::Manifest=maniread" \
	  -e "@all = keys %{ maniread() };" \
	  -e "print(qq{Executing $(CI) @all\n}); system(qq{$(CI) @all});" \
	  -e "print(qq{Executing $(RCS_LABEL) ...\n}); system(qq{$(RCS_LABEL) @all});"


# --- MakeMaker distmeta section:
distmeta : create_distdir metafile
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'exit unless -e q{META.yml};' \
	  -e 'eval { maniadd({q{META.yml} => q{Module YAML meta-data (added by MakeMaker)}}) }' \
	  -e '    or print "Could not add META.yml to MANIFEST: $${'\''@'\''}\n"' --
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'exit unless -f q{META.json};' \
	  -e 'eval { maniadd({q{META.json} => q{Module JSON meta-data (added by MakeMaker)}}) }' \
	  -e '    or print "Could not add META.json to MANIFEST: $${'\''@'\''}\n"' --



# --- MakeMaker distsignature section:
distsignature : create_distdir
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'eval { maniadd({q{SIGNATURE} => q{Public-key signature (added by MakeMaker)}}) } ' \
	  -e '    or print "Could not add SIGNATURE to MANIFEST: $${'\''@'\''}\n"' --
	$(NOECHO) cd $(DISTVNAME) && $(TOUCH) SIGNATURE
	cd $(DISTVNAME) && cpansign -s



# --- MakeMaker install section:

install :: pure_install doc_install
	$(NOECHO) $(NOOP)

install_perl :: pure_perl_install doc_perl_install
	$(NOECHO) $(NOOP)

install_site :: pure_site_install doc_site_install
	$(NOECHO) $(NOOP)

install_vendor :: pure_vendor_install doc_vendor_install
	$(NOECHO) $(NOOP)

pure_install :: pure_$(INSTALLDIRS)_install
	$(NOECHO) $(NOOP)

doc_install :: doc_$(INSTALLDIRS)_install
	$(NOECHO) $(NOOP)

pure__install : pure_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

doc__install : doc_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

pure_perl_install :: all
	$(NOECHO) $(MOD_INSTALL) \
		read $(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLARCHLIB)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLPRIVLIB) \
		$(INST_ARCHLIB) $(DESTINSTALLARCHLIB) \
		$(INST_BIN) $(DESTINSTALLBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLMAN3DIR)
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		$(SITEARCHEXP)/auto/$(FULLEXT)


pure_site_install :: all
	$(NOECHO) $(MOD_INSTALL) \
		read $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLSITEARCH)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLSITELIB) \
		$(INST_ARCHLIB) $(DESTINSTALLSITEARCH) \
		$(INST_BIN) $(DESTINSTALLSITEBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSITESCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLSITEMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLSITEMAN3DIR)
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		$(PERL_ARCHLIB)/auto/$(FULLEXT)

pure_vendor_install :: all
	$(NOECHO) $(MOD_INSTALL) \
		read $(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLVENDORARCH)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLVENDORLIB) \
		$(INST_ARCHLIB) $(DESTINSTALLVENDORARCH) \
		$(INST_BIN) $(DESTINSTALLVENDORBIN) \
		$(INST_SCRIPT) $(DESTINSTALLVENDORSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLVENDORMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLVENDORMAN3DIR)

doc_perl_install :: all
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLPRIVLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod

doc_site_install :: all
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLSITELIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod

doc_vendor_install :: all
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLVENDORLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod


uninstall :: uninstall_from_$(INSTALLDIRS)dirs
	$(NOECHO) $(NOOP)

uninstall_from_perldirs ::
	$(NOECHO) $(UNINSTALL) $(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist

uninstall_from_sitedirs ::
	$(NOECHO) $(UNINSTALL) $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist

uninstall_from_vendordirs ::
	$(NOECHO) $(UNINSTALL) $(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist


# --- MakeMaker force section:
# Phony target to force checking subdirectories.
FORCE :
	$(NOECHO) $(NOOP)


# --- MakeMaker perldepend section:


# --- MakeMaker makefile section:
# We take a very conservative approach here, but it's worth it.
# We move Makefile to Makefile.old here to avoid gnu make looping.
$(FIRST_MAKEFILE) : Makefile.PL $(CONFIGDEP)
	$(NOECHO) $(ECHO) "Makefile out-of-date with respect to $?"
	$(NOECHO) $(ECHO) "Cleaning current config before rebuilding Makefile..."
	-$(NOECHO) $(RM_F) $(MAKEFILE_OLD)
	-$(NOECHO) $(MV)   $(FIRST_MAKEFILE) $(MAKEFILE_OLD)
	- $(MAKE) $(USEMAKEFILE) $(MAKEFILE_OLD) clean $(DEV_NULL)
	$(PERLRUN) Makefile.PL "INSTALL_BASE=/home/einar/meran/intranet/modules/externos"
	$(NOECHO) $(ECHO) "==> Your Makefile has been rebuilt. <=="
	$(NOECHO) $(ECHO) "==> Please rerun the $(MAKE) command.  <=="
	$(FALSE)



# --- MakeMaker staticmake section:

# --- MakeMaker makeaperl section ---
MAP_TARGET    = perl
FULLPERL      = /usr/bin/perl

$(MAP_TARGET) :: static $(MAKE_APERL_FILE)
	$(MAKE) $(USEMAKEFILE) $(MAKE_APERL_FILE) $@

$(MAKE_APERL_FILE) : $(FIRST_MAKEFILE) pm_to_blib
	$(NOECHO) $(ECHO) Writing \"$(MAKE_APERL_FILE)\" for this $(MAP_TARGET)
	$(NOECHO) $(PERLRUNINST) \
		Makefile.PL DIR= \
		MAKEFILE=$(MAKE_APERL_FILE) LINKTYPE=static \
		MAKEAPERL=1 NORECURS=1 CCCDLFLAGS= \
		INSTALL_BASE=/home/einar/meran/intranet/modules/externos


# --- MakeMaker test section:

TEST_VERBOSE=0
TEST_TYPE=test_$(LINKTYPE)
TEST_FILE = test.pl
TEST_FILES = t/00ldif-entry.t t/01canon_dn.t t/02filter.t t/03schema.t t/04refloop.t t/05dsml.t t/06constant.t t/50populate.t t/51search.t t/52modify.t t/53schema.t t/54dse.t t/55ssl.t t/56ipc.t t/57url.t t/58lwp.t t/70sortctrl.t
TESTDB_SW = -d

testdb :: testdb_$(LINKTYPE)

test :: $(TEST_TYPE) subdirs-test

subdirs-test ::
	$(NOECHO) $(NOOP)


test_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) "-MExtUtils::Command::MM" "-e" "test_harness($(TEST_VERBOSE), 'inc', '$(INST_LIB)', '$(INST_ARCHLIB)')" $(TEST_FILES)

testdb_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) $(TESTDB_SW) "-Iinc" "-I$(INST_LIB)" "-I$(INST_ARCHLIB)" $(TEST_FILE)

test_ : test_dynamic

test_static :: test_dynamic
testdb_static :: testdb_dynamic


# --- MakeMaker ppd section:
# Creates a PPD (Perl Package Description) for a binary distribution.
ppd :
	$(NOECHO) $(ECHO) '<SOFTPKG NAME="$(DISTNAME)" VERSION="0.44">' > $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <ABSTRACT>LDAP client library</ABSTRACT>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <AUTHOR>Graham Barr &lt;gbarr@cpan.org&gt;</AUTHOR>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <PERLCORE VERSION="5,008,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Convert::ASN1" VERSION="0.07" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <ARCHITECTURE NAME="i486-linux-gnu-thread-multi-5.10" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <CODEBASE HREF="" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    </IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '</SOFTPKG>' >> $(DISTNAME).ppd


# --- MakeMaker pm_to_blib section:

pm_to_blib : $(FIRST_MAKEFILE) $(TO_INST_PM)
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)/auto'\'', q[$(PM_FILTER)], '\''$(PERM_DIR)'\'')' -- \
	  lib/Net/LDAP/Control/PostRead.pm blib/lib/Net/LDAP/Control/PostRead.pm \
	  lib/Net/LDAP/FilterMatch.pm blib/lib/Net/LDAP/FilterMatch.pm \
	  lib/Net/LDAP/Entry.pod blib/lib/Net/LDAP/Entry.pod \
	  lib/Net/LDAP/Control/SyncDone.pm blib/lib/Net/LDAP/Control/SyncDone.pm \
	  lib/Net/LDAP/Message.pod blib/lib/Net/LDAP/Message.pod \
	  lib/Net/LDAP/Util.pm blib/lib/Net/LDAP/Util.pm \
	  lib/Net/LDAP/Extension/WhoAmI.pm blib/lib/Net/LDAP/Extension/WhoAmI.pm \
	  lib/Net/LDAP/DSML.pm blib/lib/Net/LDAP/DSML.pm \
	  lib/Net/LDAP/LDIF.pm blib/lib/Net/LDAP/LDIF.pm \
	  lib/Net/LDAP/Extension/Cancel.pm blib/lib/Net/LDAP/Extension/Cancel.pm \
	  lib/Net/LDAP/LDIF.pod blib/lib/Net/LDAP/LDIF.pod \
	  lib/Net/LDAP/Filter.pod blib/lib/Net/LDAP/Filter.pod \
	  lib/Net/LDAP/Security.pod blib/lib/Net/LDAP/Security.pod \
	  lib/Net/LDAP/Control/VLV.pm blib/lib/Net/LDAP/Control/VLV.pm \
	  lib/Net/LDAP/Control/SortResult.pm blib/lib/Net/LDAP/Control/SortResult.pm \
	  lib/Net/LDAP/Control/ManageDsaIT.pm blib/lib/Net/LDAP/Control/ManageDsaIT.pm \
	  lib/Net/LDAP/Control/ProxyAuth.pm blib/lib/Net/LDAP/Control/ProxyAuth.pm \
	  lib/Net/LDAPI.pm blib/lib/Net/LDAPI.pm \
	  lib/LWP/Protocol/ldaps.pm blib/lib/LWP/Protocol/ldaps.pm \
	  lib/Net/LDAP/Control/Sort.pm blib/lib/Net/LDAP/Control/Sort.pm \
	  lib/Net/LDAPS.pm blib/lib/Net/LDAPS.pm \
	  lib/Net/LDAP/Control/SyncRequest.pm blib/lib/Net/LDAP/Control/SyncRequest.pm \
	  lib/Net/LDAP/Extension/Refresh.pm blib/lib/Net/LDAP/Extension/Refresh.pm \
	  lib/Net/LDAP/Message.pm blib/lib/Net/LDAP/Message.pm \
	  lib/Net/LDAP/Search.pm blib/lib/Net/LDAP/Search.pm \
	  lib/Net/LDAP/RootDSE.pm blib/lib/Net/LDAP/RootDSE.pm \
	  lib/Net/LDAP/FAQ.pod blib/lib/Net/LDAP/FAQ.pod \
	  lib/Net/LDAP/ASN.pm blib/lib/Net/LDAP/ASN.pm \
	  lib/Bundle/Net/LDAP.pm blib/lib/Bundle/Net/LDAP.pm \
	  lib/LWP/Protocol/ldap.pm blib/lib/LWP/Protocol/ldap.pm \
	  lib/Net/LDAP/Extra.pm blib/lib/Net/LDAP/Extra.pm \
	  lib/Net/LDAP/Control.pm blib/lib/Net/LDAP/Control.pm \
	  lib/Net/LDAP/Entry.pm blib/lib/Net/LDAP/Entry.pm \
	  lib/Net/LDAP/Control/VLVResponse.pm blib/lib/Net/LDAP/Control/VLVResponse.pm \
	  lib/Net/LDAP/Control/PersistentSearch.pm blib/lib/Net/LDAP/Control/PersistentSearch.pm \
	  lib/Net/LDAP/Schema.pm blib/lib/Net/LDAP/Schema.pm \
	  lib/Net/LDAP/Bind.pm blib/lib/Net/LDAP/Bind.pm \
	  lib/Net/LDAP/Control/PreRead.pm blib/lib/Net/LDAP/Control/PreRead.pm \
	  lib/Net/LDAP/Control/Paged.pm blib/lib/Net/LDAP/Control/Paged.pm \
	  lib/Net/LDAP/Filter.pm blib/lib/Net/LDAP/Filter.pm \
	  lib/Net/LDAP/Control/PasswordPolicy.pm blib/lib/Net/LDAP/Control/PasswordPolicy.pm \
	  lib/Net/LDAP/Control/EntryChange.pm blib/lib/Net/LDAP/Control/EntryChange.pm \
	  lib/Net/LDAP/Intermediate.pm blib/lib/Net/LDAP/Intermediate.pm 
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)/auto'\'', q[$(PM_FILTER)], '\''$(PERM_DIR)'\'')' -- \
	  lib/Net/LDAP/Schema.pod blib/lib/Net/LDAP/Schema.pod \
	  lib/Net/LDAP/Examples.pod blib/lib/Net/LDAP/Examples.pod \
	  lib/Net/LDAP/RFC.pod blib/lib/Net/LDAP/RFC.pod \
	  lib/Net/LDAP/Extension/SetPassword.pm blib/lib/Net/LDAP/Extension/SetPassword.pm \
	  lib/Net/LDAP/Intermediate/SyncInfo.pm blib/lib/Net/LDAP/Intermediate/SyncInfo.pm \
	  lib/Net/LDAP.pm blib/lib/Net/LDAP.pm \
	  lib/Net/LDAP/Control/SyncState.pm blib/lib/Net/LDAP/Control/SyncState.pm \
	  lib/Net/LDAP/Extension.pm blib/lib/Net/LDAP/Extension.pm \
	  lib/Net/LDAP/Control/MatchedValues.pm blib/lib/Net/LDAP/Control/MatchedValues.pm \
	  lib/Net/LDAP/Reference.pod blib/lib/Net/LDAP/Reference.pod \
	  lib/Net/LDAP.pod blib/lib/Net/LDAP.pod \
	  lib/Net/LDAP/Constant.pm blib/lib/Net/LDAP/Constant.pm \
	  lib/Net/LDAP/Search.pod blib/lib/Net/LDAP/Search.pod \
	  lib/Net/LDAP/Control/Assertion.pm blib/lib/Net/LDAP/Control/Assertion.pm 
	$(NOECHO) $(TOUCH) pm_to_blib


# --- MakeMaker selfdocument section:


# --- MakeMaker postamble section:


# End.
# Postamble by Module::Install 0.95
# --- Module::Install::AutoInstall section:

config :: installdeps
	$(NOECHO) $(NOOP)

checkdeps ::
	$(PERL) Makefile.PL --checkdeps

installdeps ::
	$(PERL) Makefile.PL --config= --installdeps=Convert::ASN1,0.07

