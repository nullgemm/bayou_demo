NAME = bayou_demo
CC = gcc
FLAGS = -std=c99 -pedantic -g
FLAGS+= -Wall -Wno-unused-parameter -Wextra -Werror=vla -Werror
VALGRIND = --show-leak-kinds=all --track-origins=yes --leak-check=full

BIND = bin
OBJD = obj
SRCD = src
SUBD = sub

INCL = -I$(SRCD)
SRCS = $(SRCD)/main.c

SRCS_OBJS := $(patsubst %.c,$(OBJD)/%.o,$(SRCS))

# aliases
.PHONY: final
final: $(BIND)/$(NAME)

# generic compiling command
$(OBJD)/%.o: %.c
	@echo "building object $@"
	@mkdir -p $(@D)
	@$(CC) $(INCL) $(FLAGS) -c -o $@ $<

# final executable
$(BIND)/$(NAME): $(SRCS_OBJS)
	@echo "compiling executable $@"
	@mkdir -p $(@D)
	@$(CC) -o $@ $^ $(LINK)

run:
	@cd $(BIND) && ./$(NAME)

# tools
leakgrind: $(BIND)/$(NAME)
	@rm -f valgrind.log
	@cd $(BIND) && valgrind $(VALGRIND) 2> ../valgrind.log ./$(NAME)

clean:
	@echo "cleaning"
	@rm -rf $(BIND) $(OBJD) valgrind.log

github:
	@echo "sourcing submodules from https://github.com"
	@mv .github .gitmodules
	@git submodule sync
	@git submodule update --init --recursive --remote

gitea:
	@echo "sourcing submodules from https://git.cylgom.net"
	@mv .gitea .gitmodules
	@git submodule sync
	@git submodule update --init --recursive --remote
