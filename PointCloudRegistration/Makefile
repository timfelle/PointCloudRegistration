#==============================================================================
# -- Definition

ifeq ($(OS),Windows_NT)
Win:
	@echo -e "Windows compilation not supported through make."
	@echo -e "Please use the supplied Visual Studio solution for windows"
	@echo -e "compilation"
	@exit
else
	OPEN3D = $(HOME)/local/open3d/0.4.0
	EIGEN3 = /usr/include/eigen3/
endif

# - Compilers
CXX	= g++

# - C Flags
OPTIM   =-O3
WARN    =
LIBS    =-std=c++17 -I$(OPEN3D)/include/ -I$(OPEN3D)/include/Open3D -I$(EIGEN3)
CHIP    =
PARA    =-fopenmp
LFLAGS  =-L$(OPEN3D)/lib -lOpen3D -lCore -fopenmp -lstdc++fs -Wl,-rpath,$(OPEN3D)/lib

CFLAGS  = $(OPTIM) $(WARN) $(LIBS) $(CHIP) $(PARA)

# -- End of Definitions
#==============================================================================
# -- File definitions and macros

# - Excecutable
EXEC    = Registration.exe

# - Source files
MAIN    = registration
FRAME   = utility_functions point_cloud_utility
REGIS   = fast_global_registration fast_point_feature_histograms

# - Directories
SRCDIR	= src
LIBDIR	= lib
OBJDIR	= build
FDIR 	= $(SRCDIR)/framework
RDIR    = $(SRCDIR)/registration

# - Combining files to their correct directory
SOURCES	 = $(addprefix $(FDIR)/, $(addsuffix .cpp, $(FRAME)))
SOURCES	+= $(addprefix $(SRCDIR)/, $(addsuffix .cpp, $(MAIN)))
SOURCES += $(addprefix $(RDIR)/, $(addsuffix .cpp, $(REGIS)))

OBJECTS	 = $(addprefix $(OBJDIR)/, $(addsuffix .o, $(FRAME)))
OBJECTS += $(addprefix $(OBJDIR)/, $(addsuffix .o, $(MAIN))) 
OBJECTS += $(addprefix $(OBJDIR)/, $(addsuffix .o, $(REGIS)))

# -- End of File definitions
#==============================================================================
# -- Compilations                             (Avoid changes beyond this point)

# - Main
$(EXEC) : $(OBJECTS) #DEPS
	$(CXX) -o $(EXEC) $(OBJECTS) -I$(LIBDIR) $(LFLAGS)
	@echo -e "\nmake: '$(EXEC)' was build sucessfully."

# - Dependencies
DEPS : 
	@echo -e "Make dependency: GenerateData.exe"
	@make -sf Makefile.GenerateData

# - C Files
.SUFFIXES: .cpp
$(OBJDIR)/%.o: $(SRCDIR)/%.cpp | $(OBJDIR)
	$(CXX) $(CFLAGS) -o $@ -c $< -I$(LIBDIR)
$(OBJDIR)/%.o: $(FDIR)/%.cpp | $(OBJDIR)
	$(CXX) $(CFLAGS) -o $@ -c $< -I$(LIBDIR)
$(OBJDIR)/%.o: $(RDIR)/%.cpp | $(OBJDIR)
	$(CXX) $(CFLAGS) -o $@ -c $< -I$(LIBDIR)


# -- End of compilations
#==============================================================================
# -- Utility commands
run	: $(EXEC)
	./$(EXEC)
$(OBJDIR):
	@mkdir -p $(OBJDIR)
clean :
	@make -sf Makefile.GenerateData clean 
	@rm -fr $(OBJECTS) core
realclean : clean
	@make -sf Makefile.GenerateData realclean 
	@rm -f $(EXEC)
depend :
	@make -sf Makefile.GenerateData depend
	@makedepend -Y$(LIBDIR) $(SOURCES)
	@rm -f Makefile.bak MDP.err

# -- End of utility commands
#==============================================================================
# -- Compile dependecies
# DO NOT DELETE

src/framework/utility_functions.o: lib/utility_functions.h
src/framework/point_cloud_utility.o: lib/point_cloud_utility.h
src/framework/point_cloud_utility.o: lib/utility_functions.h
src/registration.o: lib/point_cloud_utility.h lib/utility_functions.h
src/registration.o: lib/fast_point_feature_histograms.h
src/registration.o: lib/fast_global_registration.h
src/registration/fast_global_registration.o: lib/utility_functions.h
src/registration/fast_global_registration.o: lib/fast_global_registration.h
src/registration/fast_point_feature_histograms.o: lib/fast_point_feature_histograms.h
