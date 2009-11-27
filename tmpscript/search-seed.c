#include <stdio.h>

typedef unsigned int uint;
static const int TRUE = 1;
static const int FALSE = 0;

#define SEED_TO_RAND(seed) ((int)(seed >> 16))

static uint next_seed(uint seed) {
	return seed * 0x41C64E6D + 0x6073;
}

static uint prev_seed(uint seed) {
	return seed * 0xEEB9EB65 + 0xA3561A1;
}

struct entry {
	int id;
	int nature;
};

uint step_pid(uint seed, int nature) {
	int parent_id, secret_id;
	uint pid;
	parent_id = SEED_TO_RAND(seed);
	seed = next_seed(seed);
	secret_id = SEED_TO_RAND(seed);
	seed = next_seed(seed);
	do {
		int pid_row, pid_high;
		pid_row = SEED_TO_RAND(seed);
		seed = next_seed(seed);
		pid_high = SEED_TO_RAND(seed);
		seed = next_seed(seed);
		pid = (uint)pid_high << 16 | (uint)pid_row;
	} while ((int)(pid % 25) != nature);
	return seed;
}

int find_id(int id, struct entry *entries, int *visited) {
	int i;
	for (i = 0; i < 6; i ++) {
		if (!visited[i] && entries[i].id == id) {
			visited[i] = TRUE;
			return i;
		}
	}
	return -1;
}

int is_match(struct entry *entries, uint seed) {
	int visited[6] = {FALSE, FALSE, FALSE, FALSE, FALSE, FALSE};
	int i;
	for (i = 0; i < 6; i ++) {
		int id = SEED_TO_RAND(seed);
		int index = find_id(id, entries, visited);
		if (index == -1) return FALSE;
		seed = step_pid(seed, entries[index].nature);
	}
	return TRUE;
}

void print_order(struct entry *entries, uint seed) {
	int visited[6] = {FALSE, FALSE, FALSE, FALSE, FALSE, FALSE};
	int i;
	for (i = 0; i < 6; i ++) {
		int id = SEED_TO_RAND(seed);
		int index = find_id(id, entries, visited);
		if (index == -1) return;
		if (i > 0) printf(",");
		printf("%d", index);
		seed = step_pid(seed, entries[index].nature);
	}
	return;
}

int main(void) {
	struct entry entries[6];
	int i;
	printf("input id and nature.\n");
	for (i = 0; i < 6; i ++) {
		scanf("%d %d", &entries[i].id, &entries[i].nature);
	}
	int ns[] = {0, 4, 5};
	for (i = 0; i < 3; i ++) {
		int n = ns[i];
		int row;
		for (row = 0; row < 65536; row ++) {
			uint seed = (uint)entries[n].id << 16 | row;
			if (is_match(entries, seed)) {
				printf("0x%.8x", seed);
				printf(" (");
				print_order(entries, seed);
				printf(")\n");
			}
		}
	}
	printf("finish\n");
	return 0;
}
