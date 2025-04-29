# QUIC Steps: Evaluating Pacing Strategies in QUIC Implementations

This repository containes artifacts accompanying the paper **QUIC Steps: Evaluating Pacing Strategies in QUIC Implementations** by Marcel Kempf, Simon Tietz, Benedikt Jaeger, Johannes Späth, Georg Carle, and Johannes Zirngibl.
The paper will be presented at [CoNEXT 2025](https://conferences.sigcomm.org/co-next/2025/#!/home), published in the [Proceedings of the ACM on Networking](https://dl.acm.org/journal/pacmnet) and can be accessed under [DOI:10.1145/3730985](https://doi.org/10.1145/3730985).

If you could find our work useful, consider citing our paper. 

You can use:

```bibtex
@article{10.1145/3730985,
  author = {Kempf, Marcel and Tietz, Simon and Jaeger, Benedikt and Sp{\"a}th, Johannes and Carle, Georg and Zirngibl, Johannes},
  title = {{QUIC Steps: Evaluating Pacing Strategies in QUIC Implementations}},
  year = {2025},
  issue_date = {June 2025},
  publisher = {Association for Computing Machinery},
  address = {New York, NY, USA},
  volume = {3},
  number = {CoNEXT2},
  url = {https://doi.org/10.1145/3730985},
  doi = {10.1145/3730985},
  journal = {Proc. ACM Netw.},
  month = jun,
  articleno = {13},
  keywords = {QUIC, Pacing, Congestion Control, GSO, Queueing Disciplines, Measurement Framework}
}
```

## 📦 Repository Content

This repository provides the necessary components to reproduce the measurements and results presented in the paper, as well as a framework for further research into QUIC pacing. The content includes:

* ⚙️ [**Measurement Framework:**](#️-measurement-framework) The source code for our custom measurement framework, which extends the framework presented by Jaeger et al. in *[QUIC on the Highway: Evaluating Performance on High Rate Links](http://doi.org/10.23919/IFIPNetworking57963.2023.10186365)*. The framework is designed for reproducible QUIC experiments on bare-metal servers.
* 📄 [**Configurations:**](#-configurations) Configuration files used to set up the network environment, QUIC implementations, and measurement parameters for all experiments presented in the paper.
* 🩹 [**Patches:**](#-patches) Patches applied to the evaluated QUIC libraries (quiche) and the Linux kernel (for paced GSO) to enable specific functionalities and behaviors studied in the paper.
* 📂 [**Measurement Data:**](#-measurement-data) The collected raw data from our experiments, including detailed logs from the QUIC implementations and systems, and packet captures from the sniffer host.
* 📊 [**Evaluation Scripts:**](#-evaluation-scripts) Scripts used to process the raw measurement data and generate the figures and data presented in the paper.

## ⚙️ Measurement Framework

Coming soon

## 📄 Configurations

Coming soon

## 🩹 Patches

Coming soon

## 📂 Measurement Data

In the [results directory](results), you will find the raw measurement data collected during our experiments.
The data is divided into two subdirectories: `pcaps` (containing all pcap files) and `detailed` (containing all remaining logs for the individual measurements).
All files are compressed using [zstd](https://facebook.github.io/zstd/) for efficient storage and transmission.
While the pcap files are compressed individually, the detailed logs are compressed in a tarball format.
You can use the four provided scripts to [de]compress the files.

## 📊 Evaluation Scripts

The evaluation scripts are located in the [analysis directory](analysis).
The script names should be executed in the order of the numbers in the file names.
* The first script, `01_preprocessing.py`, will take a while, as all pcap files are processed. The script will place all generated data under [analysis/build/data](analysis/build/data). Known pcaps will be skipped so that the script runs faster on subsequent runs.
* The second script, `02_plotting.py`, will generate the cdf plots presented in the paper. All generated figures are stored as `.pdf` under [analysis/build/figures](analysis/build/figures).

> [!TIP]
> As our measurement framework extends the one presented by Jaeger et al. in *[QUIC on the Highway: Evaluating Performance on High Rate Links](http://doi.org/10.23919/IFIPNetworking57963.2023.10186365)*, the [scripts provided back then](https://github.com/tumi8/quic-10g-paper) do also work for our data.

## 📧 Contact

For questions regarding the artifacts or the paper, feel free to reach out to the first author:\
Marcel Kempf (kempfm@net.in.tum.de).
