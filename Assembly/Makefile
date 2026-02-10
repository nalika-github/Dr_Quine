NASM = nasm
CC = gcc
NASM_FLAGS = -f elf64
CC_FLAGS = -no-pie

COLLEEN = Colleen
GRACE = Grace
SULLY = Sully

NAME = $(COLLEEN) $(GRACE) $(SULLY)

SRC_COLLEEN = Colleen.s
SRC_GRACE = Grace.s
SRC_SULLY = Sully.s

OBJ_DIR = obj
OBJ_COLLEEN = $(OBJ_DIR)/Colleen.o
OBJ_GRACE = $(OBJ_DIR)/Grace.o
OBJ_SULLY = $(OBJ_DIR)/Sully.o

EXC_DIR = exc
EXC_COLLEEN = $(EXC_DIR)/$(COLLEEN)
EXC_GRACE = $(EXC_DIR)/$(GRACE)
EXC_SULLY = $(EXC_DIR)/$(SULLY)

all: $(EXC_COLLEEN) $(EXC_GRACE) $(EXC_SULLY)

$(EXC_COLLEEN): $(OBJ_COLLEEN) | $(EXC_DIR)
	@$(CC) $(CC_FLAGS) $(OBJ_COLLEEN) -o $(EXC_COLLEEN)

$(EXC_GRACE): $(OBJ_GRACE) | $(EXC_DIR)
	@$(CC) $(CC_FLAGS) $(OBJ_GRACE) -o $(EXC_GRACE)

$(EXC_SULLY): $(OBJ_SULLY) | $(EXC_DIR)
	@$(CC) $(CC_FLAGS) $(OBJ_SULLY) -o $(EXC_SULLY)

$(OBJ_COLLEEN): $(SRC_COLLEEN) | $(OBJ_DIR)
	@$(NASM) $(NASM_FLAGS) $(SRC_COLLEEN) -o $(OBJ_COLLEEN)

$(OBJ_GRACE): $(SRC_GRACE) | $(OBJ_DIR)
	@$(NASM) $(NASM_FLAGS) $(SRC_GRACE) -o $(OBJ_GRACE)

$(OBJ_SULLY): $(SRC_SULLY) | $(OBJ_DIR)
	@$(NASM) $(NASM_FLAGS) $(SRC_SULLY) -o $(OBJ_SULLY)

$(OBJ_DIR):
	@mkdir -p $(OBJ_DIR)

$(EXC_DIR):
	@mkdir -p $(EXC_DIR)

clean:
	@rm -rf $(OBJ_DIR)

fclean: clean
	@rm -rf $(EXC_DIR)
	@rm -f *_kid.s Sully_*.s Sully_*.o Sully_[0-9]

re: fclean all

.PHONY: all clean fclean re
