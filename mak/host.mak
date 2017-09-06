.PHONY: host

##==============================================================================
##
## PROGRAM
## SOURCES
##
##==============================================================================

ifndef PROGRAM
  $(error "Please define PROGRAM")
endif

ifndef SOURCES
  $(error "Please define SOURCES")
endif

##==============================================================================
##
## CFLAGS
## CXXFLAGS
##
##==============================================================================

CFLAGS += -Wall -Werror -g -O2 -fPIC
CXXFLAGS += $(CFLAGS)
CXXFLAGS += -std=c++11

##==============================================================================
##
## INCLUDES
##
##==============================================================================

INCLUDES = -I$(INCDIR)

##==============================================================================
##
## DEFINES
##
##==============================================================================

ifdef HAVE_SGX
DEFINES += -DCREATE_FLAGS=OE_FLAG_DEBUG
else
DEFINES += -DCREATE_FLAGS="OE_FLAG_DEBUG|OE_FLAG_SIMULATE"
endif

##==============================================================================
##
## OBJECTS -- form list of C and C++ objects
##
##==============================================================================

__OBJECTS = $(SOURCES:.c=.o)
OBJECTS = $(__OBJECTS:.cpp=.o)

##==============================================================================
##
## __COMPILER -- select compiler based on object lists
##
##==============================================================================

ifneq ($(__OBJECTS),$(OBJECTS))
  __COMPILER=$(CXX)
else
  __COMPILER=$(CC)
endif

##==============================================================================
##
## LDFLAGS:
##
##==============================================================================

LDFLAGS += -g -rdynamic -L$(LIBDIR)/host -loehost -lcrypto -ldl -lpthread

##==============================================================================
##
## build -- build the program
##
##==============================================================================

build: depend
	$(MAKE) $(PROGRAM)

$(PROGRAM): $(OBJECTS) $(LIBRARIES)
	$(__COMPILER) $(OBJECTS) -o $(PROGRAM) $(LIBRARIES) $(LDFLAGS)

##==============================================================================
##
## C and C++ compile rules
##
##==============================================================================

%.o: %.c
	$(CC) -c $(CFLAGS) $(DEFINES) $(INCLUDES) -o $@ $<

%.o: %.cpp
	$(CXX) -c $(CXXFLAGS) $(DEFINES) $(INCLUDES) -o $@ $<

##==============================================================================
##
## clean
##
##==============================================================================

clean:
	rm -f $(PROGRAM) $(OBJECTS) $(CLEAN) .depends

include $(MAKDIR)/depend.mak
