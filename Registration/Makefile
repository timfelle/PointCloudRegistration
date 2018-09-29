#==============================================================================
# -- Definitions

# - Compilers
CXX	= g++

# - C Flags
OPTIM   =-O3
WARN    =-Wall
LIBS    =-std=c++14
CHIP    =
PARA    =
LFLAGS  =

CFLAGS  = $(OPTIM) $(WARN) $(LIBS) $(CHIP) $(PARA)

# -- End of Definitions
#==============================================================================
# -- File definitions and macros

# - Excecutable
EXEC    = registration.bin

# - Source files
FRAME   = main plyloader

# - Directories
SRCDIR	= src
LIBDIR	= lib
OBJDIR	= obj
FDIR 	= $(SRCDIR)/framework

# - Combining files to their correct directory
SOURCES	 = $(addprefix $(FDIR)/, $(addsuffix .cpp, $(FRAME)))
# SOURCES	+= $(addprefix $(FDIR)/, $(addsuffix .cu, $(CUJOBJS)))

OBJECTS	 = $(addprefix $(OBJDIR)/, $(addsuffix .o, $(FRAME)))

# -- End of File definitions
#==============================================================================
# -- Compilations                             (Avoid changes beyond this point)

# - Main
$(EXEC) : $(OBJECTS)
	$(CXX) -o $(EXEC) $(OBJECTS) -I$(LIBDIR) $(LFLAGS)
	@echo -e "\nmake: '$(EXEC)' was build sucessfully."

# - C Files
.SUFFIXES: .cpp
$(OBJDIR)/%.o: $(FDIR)/%.cpp | $(OBJDIR)
	$(CXX) -o $@ -c $< -I$(LIBDIR) $(CFLAGS)

# -- End of compilations
#==============================================================================
# -- Utility commands
run	: $(EXEC)
	./$(EXEC)
$(OBJDIR):
	@mkdir -p $(OBJDIR)
clean :
	@rm -fr $(OBJDIR) core
realclean : clean
	@rm -f $(EXEC)
depend :
	makedepend -Y$(LIBDIR) $(SOURCES)
	@rm -f Makefile.bak MDP.err

# -- End of utility commands
#==============================================================================
# -- Compile dependecies
# DO NOT DELETE