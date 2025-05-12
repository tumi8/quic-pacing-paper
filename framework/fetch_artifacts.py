import argparse
import os
import sys
import gitlab
import zipfile
import io
from termcolor import colored
import logging

from implementations import IMPLEMENTATIONS

logging.basicConfig(
    format='%(asctime)s %(levelname)s %(message)s',
    datefmt='%m-%d %H:%M:%S'
)

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)


class ZipFileWithPermissions(zipfile.ZipFile):
    """ Custom ZipFile class handling file permissions.
        From https://stackoverflow.com/a/54748564 """
    def _extract_member(self, member, targetpath, pwd):
        if not isinstance(member, zipfile.ZipInfo):
            member = self.getinfo(member)

        targetpath = super()._extract_member(member, targetpath, pwd)

        attr = member.external_attr >> 16
        if attr != 0:
            os.chmod(targetpath, attr)
        return targetpath


def main(args):
    GITLAB_TOKEN = os.getenv('GITLAB_TOKEN')
    CI_JOB_TOKEN = os.getenv('CI_JOB_TOKEN')
    gitlab_url = 'https://gitlab.lrz.de'

    if GITLAB_TOKEN:
        logger.info('Using GITLAB_TOKEN')
        gl = gitlab.Gitlab(gitlab_url, private_token=GITLAB_TOKEN)
    elif CI_JOB_TOKEN:
        logger.info('Using CI_JOB_TOKEN')
        gl = gitlab.Gitlab(gitlab_url, job_token=os.environ['CI_JOB_TOKEN'])
    else:
        logger.error('Set GITLAB_TOKEN or CI_JOB_TOKEN')
        exit(1)

    implementations = {}
    if args.implementations:
        for s in args.implementations:
            if s not in [n for n, _ in IMPLEMENTATIONS.items()]:
                sys.exit("implementation " + s + " not found.")
            implementations[s] = IMPLEMENTATIONS[s]
    else:
        implementations = IMPLEMENTATIONS

    successful = 0
    errors = 0

    for name, value in implementations.items():
        project_id = value.get("project_id")

        if not project_id:
            logger.info(colored(f'{name}: no Gitlab project id specified, skipping.', 'yellow'))
            continue

        outpath = os.path.join(args.output_directory, name)
        os.makedirs(outpath, exist_ok=True)

        # Get project
        project = gl.projects.get(project_id, lazy=True)

        # Get branch, use main if not set
        ref = value.get('branch', 'main')

        # Get latest build artifact and extract
        try:
            for job in project.jobs.list(all=True):
                if job.ref == ref and job.name == 'build' and job.status == 'success':
                    artifacts = job.artifact(path='/artifact.zip')
                    ZipFileWithPermissions(io.BytesIO(artifacts)).extractall(path=outpath)
                    logger.info(colored(f'{name}: artifacts pulled successfully for {ref}.', 'green'))
                    successful += 1
                    break
        except gitlab.exceptions.GitlabGetError:
            logger.info(colored(f'{name}: failed to pull artifacts.', 'red'))
            errors += 1
        except zipfile.BadZipFile:
            logger.info(colored(f'{name}: failed to pull artifacts.', 'red'))
            errors += 1
    logger.info(f'{successful}/{successful + errors} artifacts downloaded.')


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--implementations", help="implementations to pull", nargs='*')
    parser.add_argument("-o", "--output_directory", help="write output to this directory", default='out')
    args = parser.parse_args()
    main(args)
