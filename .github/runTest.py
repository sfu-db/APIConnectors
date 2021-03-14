import sys
from pathlib import Path

# look for changed directories
changed_directory = set()

for file in sys.argv[1]:
	print("changed files:", file)
	cur_path = Path(file)
	cur_parent = cur_path.parent
	if cur_parent not in changed_directory:
		changed_directory.add(cur_parent)


# get config files under the repo
config_repos = []
for folder in Path('../api-connectors'):
	print('we support:', folder)
	config_repos.append(folder)


# run test on affected directories
for folder in changed_directory:
	test_file = folder
	print(test_file)

