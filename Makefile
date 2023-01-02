SRC_DIR			:=		.
TEST_DIR		:=		test

PROJECT			:=		example
TARGET			:=		$(PROJECT).nes
DEBUG			:=		$(PROJECT).nes.dbg
SOURCES			:=		$(shell find $(SRC_DIR) -type f -name '*.s')
OBJECTS			:=		$(SOURCES:%.s=%.o)
NES_CFG			:=		example.cfg

TEST			:=		$(shell find $(TEST_DIR) -type f -name '*.test.json' | sort)
TEST_IDS		:=		$(TEST:%.test.json=%.test) $(TEST_FAIL:%.test.json=%.test)

AS			:=		ca65
ASFLAGS			:=		--cpu 6502 --target nes --debug-info
LD			:=		ld65
LDFLAGS			:=		
TEST_EXEC		:=		6502_tester
TEST_EXEC_URL		:=		https://github.com/AsaiYusuke/6502_test_executor/releases/latest/download/linux.tar.bz2

.PHONY : all build test clean

all : build test

build : $(TARGET)

$(TARGET) : $(OBJECTS) $(NES_CFG)
	$(LD) $(LDFLAGS) -o $(TARGET) --dbgfile $(DEBUG) --config $(NES_CFG) --obj $(OBJECTS)

%.o : %.asm
	$(AS) $(ASFLAGS) -o $@ $<

test : $(TEST_EXEC) $(TEST_IDS)
	@echo "All tests passed."

$(TEST_EXEC) :
	curl -s -o - -L $(TEST_EXEC_URL) | tar xj $(TEST_EXEC)

$(TEST_DIR)/%.test : $(TEST_DIR)/%.test.json
	./$(TEST_EXEC) --debug=$(DEBUG) -t $<

clean :
	-rm $(TARGET)
	-rm $(DEBUG)
	-rm $(OBJECTS)
