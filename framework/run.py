#!/usr/bin/env python3

import argparse
import ast
import sys
import yaml

from typing import List, Tuple
from yaml.scanner import ScannerError

import testcases

from implementations import IMPLEMENTATIONS
from implementations import parse_filesize
from interop import InteropRunner
from testcases import MEASUREMENTS, TESTCASES


def main():
    def get_args():
        parser = argparse.ArgumentParser()
        parser.add_argument(
            "-d",
            "--debug",
            action="store_const",
            const=True,
            default=False,
            help="turn on debug logs",
        )
        parser.add_argument(
            "-m",
            "--manual-mode",
            action="store_true",
            help="only prepare the tests and print out the server and client run commands (to be executed manually)"
        )
        parser.add_argument(
            "--config",
            metavar="config.yml",
            help="File containing argument values"
        )
        parser.add_argument(
            "-6", "--enable-ipv6", action="store_true", default=False, dest="v6",  # dest allows accessing it
            help="Enables IPv6 execution in the interop runner"
        )
        parser.add_argument(
            "-s", "--server", help="server implementations (comma-separated)"
        )
        parser.add_argument(
            "-c", "--client", help="client implementations (comma-separated)"
        )
        parser.add_argument(
            "-t",
            "--test",
            help="test cases (comma-separatated). Valid test cases are: "
                 + ", ".join([x.name() for x in TESTCASES + MEASUREMENTS]),
        )
        parser.add_argument(
            "-l",
            "--log-dir",
            help="log directory",
            default="",
        )
        parser.add_argument(
            "-f", "--save-files", help="save downloaded files if a test fails"
        )
        parser.add_argument(
            "-i", "--implementation-directory",
            help="Directory containing the implementations."
                 "This is prepended to the 'path' in the implementations.json file."
                 "Default: .",
            default='.'
        )
        parser.add_argument(
            "-j", "--json", help="output the matrix to file in json format"
        )
        parser.add_argument(
            "--venv-dir",
            help="dir to store venvs",
            default="",
        )
        parser.add_argument(
            "--testbed",
            help="Runs the measurement in testbed mode. Requires a json file with client/server information"
        )
        parser.add_argument(
            "--bandwidth",
            help="Set a link bandwidth value which will be enforced using tc. Is only set in testbed mode on the remote hosts. Set values in tc syntax, e.g. 100mbit, 1gbit"
        )
        parser.add_argument(
            "--delay",
            help="Add the chosen delay to packets sent to the client interface using tc. Set values in milliseconds, "
                 "e.g. --delay 10ms"
        )
        parser.add_argument(
            "--reorder",
            nargs=2,
            help="Add random reordering to packets sent to the client interface using tc. It is required to set a "
                 "delay value for using this option. Two percentage values are required for this option. The first is "
                 "the percentage of packets immediately sent and the second is the correlation ,"
                 "e.g. --reorder-packets 25%% 50%%"
        )
        parser.add_argument(
            "--corruption",
            help="Add random noise corruption using tc. This option introduces a single bit error at a random offset "
                 "in the packet. Set value in percentage, e.g. --corruption 0.1%%"
        )
        parser.add_argument(
            "--loss",
            help="Add random packet loss specified in the 'tc' command in percentage, e.g. --loss 0.1%%"
        )
        # TODO: Maybe add option for packet duplication too

        # Handle Pre-/Postscripts for server and client
        script_variable_help_msg = ("Available pos variables to use: "
                                    "interface (the interface we send/receive on, e.g enp123test), "
                                    "hostname, log_dir (the directory where all logs are saved to)")
        script_server_vars = ", www_dir (server root when serving files), certs_dir (folder of the certificates)"
        script_client_vars = ", sim_log_dir, download_dir"
        parser.add_argument(
            "-snifpre",
            "--sniffer-prerunscript",
            default=[],
            nargs="*",
            metavar="SCRIPT",
            help="Add a bash script which should be executed before a test run on the sniffer server using pos. " + script_variable_help_msg + script_server_vars,
        )
        parser.add_argument(
            "-snifpost",
            "--sniffer-postrunscript",
            default=[],
            nargs="*",
            metavar="SCRIPT",
            help="Add a bash script which should be executed before a test run on the sniffer server using pos. " + script_variable_help_msg + script_server_vars,
        )
        parser.add_argument(
            "-spre",
            "--server-prerunscript",
            default=[],
            nargs="*",
            metavar="SCRIPT",
            help="Add a bash script which should be executed before a test run on the server using pos. " + script_variable_help_msg + script_server_vars,
        )
        parser.add_argument(
            "-sprehot",
            "--server-prerunscript-hot",
            default=[],
            nargs="*",
            metavar="SCRIPT",
            help="Add a bash script which should be executed at the first hold stage (client/server called begin()) " + script_variable_help_msg + script_server_vars,
        )
        parser.add_argument(
            "-sposthot",
            "--server-postrunscript-hot",
            default=[],
            nargs="*",
            metavar="SCRIPT",
            help="Add a bash script which should be executed at the second hold stage (client/server called end()) " + script_variable_help_msg + script_server_vars,
        )
        parser.add_argument(
            "-spost",
            "--server-postrunscript",
            default=[],
            nargs="*",
            metavar="SCRIPT",
            help="Add a bash script which should be executed after a test run on the server using pos. " + script_variable_help_msg + script_server_vars,
        )
        parser.add_argument(
            "-cpre",
            "--client-prerunscript",
            default=[],
            nargs="*",
            metavar="SCRIPT",
            help="Add a bash script which should be executed before a test run on the client using pos. " + script_variable_help_msg + script_client_vars,
        )
        parser.add_argument(
            "-cprehot",
            "--client-prerunscript-hot",
            default=[],
            nargs="*",
            metavar="SCRIPT",
            help="Add a bash script which should be executed at the first hold stage (client/server called begin()) " + script_variable_help_msg + script_client_vars,
        )
        parser.add_argument(
            "-cposthot",
            "--client-postrunscript-hot",
            default=[],
            nargs="*",
            metavar="SCRIPT",
            help="Add a bash script which should be executed at the second hold stage (client/server called end()) " + script_variable_help_msg + script_client_vars,
        )
        parser.add_argument(
            "-cpost",
            "--client-postrunscript",
            default=[],
            nargs="*",
            metavar="SCRIPT",
            help="Add a bash script which should be executed after a test run on the client using pos. " + script_variable_help_msg + script_client_vars,
        )
        parser.add_argument(
            "--client-implementation-params",
            nargs="*",
            metavar="KEY=VALUE",
            help="",
            default=[]
        )
        parser.add_argument(
            "--server-implementation-params",
            nargs="*",
            metavar="KEY=VALUE",
            help="",
            default=[]
        )
        parser.add_argument(
            "--sniffer-params",
            nargs="*",
            metavar="KEY=VALUE",
            help="",
            default=[]
        )
        parser.add_argument(
            "--disable-server-aes-offload",
            action="store_const",
            const=True,
            default=False,
            help="turn server aes offload off",
        )
        parser.add_argument(
            "--disable-client-aes-offload",
            action="store_const",
            const=True,
            default=False,
            help="turn client aes offload off",
        )
        parser.add_argument(
            "--filesize",
            help="Set the filesize of the transmitted file for all measurements. If no unit is specified MiB is assumed."
        )
        parser.add_argument(
            "--repetitions",
            metavar="N",
            type=int,
            help="Set the number of repetitions for all measurements."
        )
        parser.add_argument(
            "--continue-on-error",
            action="store_true",
            help="Continue measurement even if a measurement fails."
        )
        parser.add_argument(
            "--use-client-timestamps",
            action="store_true",
            help="Try to parse timestamps written by the client for computing goodput."
        )
        parser.add_argument(
            "--only-same-implementation",
            action="store_true",
            help="Test implementations only against their counterpart."
        )

        args = parser.parse_args()
        if args.config:
            config_args = parse_config(args.config)
            parser.set_defaults(**config_args)
            # Ensure that every config file argument is defined in the parser
            for k, _ in config_args.items():
                if k not in args:
                    sys.exit(f"Argument '{k}' from config file was not recognized by the parser.")
            args = parser.parse_args()

        return args

    def parse_config(config_file):
        try:
            with open(config_file, 'r') as f:
                model_config = yaml.safe_load(f)
            return model_config
        except ScannerError:
            sys.exit("config file syntax error!")
        except FileNotFoundError:
            sys.exit("config file not found!")

    def get_dict_arg(arg):
        """Given: list containing one KV pair
                    per entry
        Return: dict containing all KV pairs
                    from the list
        """
        output = {}
        if not arg:
            return output
        for item in arg:
            if type(item) is dict:
                output = {**output, **item}
            else:
                try:
                    k, v = item.split('=', 1)
                except ValueError:
                    # handle entries without equals symbol as bool set to True
                    output[item] = True
                    continue
                try:
                    output[k] = ast.literal_eval(v)
                except (ValueError, SyntaxError):
                    output[k] = v
        return output

    def get_impls(arg, availableImpls, role) -> List[str]:
        if not arg:
            return availableImpls
        impls = []
        arg = arg.replace(" ", "").replace("\n", "")
        for s in arg.replace(" ", "").split(","):
            if s not in availableImpls:
                sys.exit(role + " implementation " + s + " not found.")
            impls.append(s)
        return impls

    def get_tests_and_measurements(
            arg,
            filesize,
            repetitions,
    ) -> Tuple[List[testcases.TestCase], List[testcases.Measurement]]:
        if arg is None:
            return TESTCASES, MEASUREMENTS
        elif arg == "onlyTests":
            return TESTCASES, []
        elif arg == "onlyMeasurements":
            return [], MEASUREMENTS
        elif not arg:
            return [], []
        tests = []
        measurements = []
        for t in arg.split(","):
            if t in [tc.name() for tc in TESTCASES]:
                tests += [tc for tc in TESTCASES if tc.name() == t]
            elif t in [tc.name() for tc in MEASUREMENTS]:
                measurement = [tc for tc in MEASUREMENTS if tc.name() == t]
                if filesize:
                    measurement[0].FILESIZE = parse_filesize(str(filesize), default_unit="MiB")
                if repetitions:
                    measurement[0].REPETITIONS = int(repetitions)
                measurements += measurement
            else:
                print(
                    (
                        "Test case {} not found.\n"
                        "Available testcases: {}\n"
                        "Available measurements: {}"
                    ).format(
                        t,
                        ", ".join([t.name() for t in TESTCASES]),
                        ", ".join([t.name() for t in MEASUREMENTS]),
                    )
                )
                sys.exit()
        return tests, measurements

    args = get_args()
    args.server_implementation_params = get_dict_arg(args.server_implementation_params)
    args.client_implementation_params = get_dict_arg(args.client_implementation_params)
    args.sniffer_params = get_dict_arg(args.sniffer_params)

    tests, measurements = get_tests_and_measurements(
        args.test,
        args.filesize,
        args.repetitions
    )

    # Check if reorder packets option is set without delay
    if args.reorder and (args.delay is None):
        print("--reorder requires --delay")
        return 1

    if args.manual_mode and not args.testbed:
        print("Manual mode is currently only supported in testbed mode!")
        return 1

    return InteropRunner(
        implementations=IMPLEMENTATIONS,
        implementations_directory=args.implementation_directory,
        servers=get_impls(args.server, IMPLEMENTATIONS, "Server"),
        clients=get_impls(args.client, IMPLEMENTATIONS, "Client"),
        tests=tests,
        measurements=measurements,
        output=args.json,
        debug=args.debug,
        manual_mode=args.manual_mode,
        log_dir=args.log_dir,
        save_files=args.save_files,
        venv_dir=args.venv_dir,
        testbed=args.testbed,
        bandwidth=args.bandwidth,
        server_pre_scripts=args.server_prerunscript,
        server_pre_hot_scripts=args.server_prerunscript_hot,
        server_post_hot_scripts=args.server_postrunscript_hot,
        server_post_scripts=args.server_postrunscript,
        client_pre_scripts=args.client_prerunscript,
        client_pre_hot_scripts=args.client_prerunscript_hot,
        client_post_hot_scripts=args.client_postrunscript_hot,
        client_post_scripts=args.client_postrunscript,
        sniffer_pre_scripts=args.sniffer_prerunscript,
        sniffer_post_scripts=args.sniffer_postrunscript,
        reorder_packets=args.reorder,
        delay=args.delay,
        corruption=args.corruption,
        loss=args.loss,
        client_implementation_params=args.client_implementation_params,
        server_implementation_params=args.server_implementation_params,
        sniffer_params=args.sniffer_params,
        disable_server_aes_offload=args.disable_server_aes_offload,
        disable_client_aes_offload=args.disable_client_aes_offload,
        continue_on_error=args.continue_on_error,
        use_client_timestamps=args.use_client_timestamps,
        only_same_implementation=args.only_same_implementation,
        use_v6=args.v6,
        args=vars(args),
    ).run()


if __name__ == "__main__":
    sys.exit(main())
