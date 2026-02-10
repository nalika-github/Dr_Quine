COLLEEN = exc/Colleen
GRACE = exc/Grace
SULLY = exc/Sully

NAME = $(COLLEEN) $(GRACE) $(SULLY)

SRC_DIR = src
SRC_COLLEEN = $(SRC_DIR)/Colleen.c
SRC_GRACE = $(SRC_DIR)/Grace.c
SRC_SULLY = $(SRC_DIR)/Sully.c

OBJ_DIR = obj
OBJ_COLLEEN = $(OBJ_DIR)/Colleen.o
OBJ_GRACE = $(OBJ_DIR)/Grace.o
OBJ_SULLY = $(OBJ_DIR)/Sully.o

FLAGS = -Wall -Werror -Wextra

all: $(NAME)

$(COLLEEN): $(OBJ_COLLEEN) | exc
	@gcc $(OBJ_COLLEEN) -o $(COLLEEN)

$(GRACE): $(OBJ_GRACE) | exc
	@gcc $(OBJ_GRACE) -o $(GRACE)

$(SULLY): $(OBJ_SULLY) | exc
	@gcc $(OBJ_SULLY) -o $(SULLY)

$(OBJ_COLLEEN): $(SRC_COLLEEN) | $(OBJ_DIR)
	@gcc -c $(FLAGS) $(SRC_COLLEEN) -o $(OBJ_COLLEEN)

$(OBJ_GRACE): $(SRC_GRACE) | $(OBJ_DIR)
	@gcc -c $(FLAGS) $(SRC_GRACE) -o $(OBJ_GRACE)

$(OBJ_SULLY): $(SRC_SULLY) | $(OBJ_DIR)
	@gcc -c $(FLAGS) $(SRC_SULLY) -o $(OBJ_SULLY)

$(OBJ_DIR):
	@mkdir -p $(OBJ_DIR)

exc:
	@mkdir -p exc

clean:
	@rm -rf $(OBJ_DIR)

fclean: clean
	@rm -rf exc

re: fclean all

.PHONY : all clean fclean re
