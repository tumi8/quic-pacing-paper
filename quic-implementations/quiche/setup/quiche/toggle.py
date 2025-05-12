import sys
import os


def main():
    argv = sys.argv
    if len(argv) != 3:
        print("substring must be provided in quotes after filename")
        exit(1)
    path = argv[1]
    substr = argv[2]
    abspath = os.path.abspath(__file__)
    dname = os.path.dirname(abspath)
    os.chdir(dname)
    with open(path, "r+") as f:
        lines = f.readlines()
        found = False
        for i in range(len(lines)):
            line = lines[i]
            if line.find(substr) != -1:
                found = True
                msg = f"line {i}: toggling \"{substr}\" =>"
                if line.strip().find("//") == 0:
                    print(msg, "on")
                    lines[i] = line.replace("//", "", 1)
                else:
                    print(msg, "off")
                    lines[i] = "//" + line
        if not found:
            print("could not find target")
            exit(1)
        f.seek(0)
        f.writelines(lines)
        f.truncate()


if __name__ == "__main__":
    main()
