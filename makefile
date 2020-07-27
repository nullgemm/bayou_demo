NAME = bayou_demo
CC = gcc
FLAGS = -std=c99 -pedantic -g
FLAGS+= -Wall -Wno-unused-parameter -Wextra -Werror=vla -Werror
VALGRIND = --show-leak-kinds=all --track-origins=yes --leak-check=full

BIND = bin
OBJD = obj
SRCD = src
SUBD = sub

INCL = -I$(SRCD) -I$(SUBD)/bayou/src -I$(SUBD)/termbox_next/src
SRCS = $(SRCD)/main.c
SRCS+= $(SUBD)/bayou/src/bayou.c
SRCS+= $(SUBD)/bayou/src/short.c

SRCS_OBJS := $(patsubst %.c,$(OBJD)/%.o,$(SRCS))
SRCS_OBJS += $(SUBD)/termbox_next/bin/termbox.a

# aliases
.PHONY: final
final: $(BIND)/$(NAME)

# generic compiling command
$(OBJD)/%.o: %.c
	@echo "building object $@"
	@mkdir -p $(@D)
	@$(CC) $(INCL) $(FLAGS) -c -o $@ $<

$(SUBD)/termbox_next/bin/termbox.a:
	@echo "building static object $@"
	@(cd $(SUBD)/termbox_next && $(MAKE))

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
	@cp .github .gitmodules
	@git submodule sync
	@git submodule update --init --remote
	@cd $(SUBD)/bayou && make github
	@git submodule update --init --recursive --remote

gitea:
	@echo "sourcing submodules from personal server"
	@cp .gitea .gitmodules
	@git submodule sync
	@git submodule update --init --remote
	@cd $(SUBD)/bayou && make gitea
	@git submodule update --init --recursive --remote
