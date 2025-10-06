<h1 align="center">Endpoint Management Scripts</h1>

<p align="center">
    <a href="https://www.linkedin.com/in/nicholas-tabb-30800b232"><img src="https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555" alt="LinkedIn"></a>
    <a href="https://github.com/elliepup/endpoint-management-scripts/blob/main/LICENSE"><img src="https://img.shields.io/github/license/elliepup/endpoint-management-scripts.svg?style=for-the-badge" alt="MIT License"></a>
</p>

---

## About

This repository is a collection of **PowerShell scripts** for **Intune remediations** and **SCCM configuration baselines**. It mainly consists of the more commonly used ones in my work as a systems administrator.

---

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

> None.

### Installation

```bash
git clone https://github.com/elliepup/endpoint-management-scripts.git
```

---

## Usage

1. Open the [Intune Portal](https://intune.microsoft.com/).
2. Navigate to `Devices > Remediations` → <kbd>Create script package</kbd>
     <br><img src="images/intune-remediation/intune-remediation_1.png" width="500">
3. Give your script a meaningful name and description.
     <br><img src="images/intune-remediation/intune-remediation_2.png" width="500">
4. Upload detection & remediation scripts. Select **64-bit PowerShell**.
     <br><img src="images/intune-remediation/intune-remediation_3.png" width="500">
5. Assign Scope: (Optional) Choose scope tags.
6. Select target groups and set the remediation schedule.
     <br><img src="images/intune-remediation/intune-remediation_4.png" width="500">

---

## Contributing

Open source thrives on collaboration!  
**How to contribute:**

```bash
# 1. Fork the repo
# 2. Create your feature branch
git checkout -b feature/AmazingFeature

# 3. Commit your changes
git commit -m "Add some AmazingFeature"

# 4. Push to your branch
git push origin feature/AmazingFeature

# 5. Open a Pull Request
```

---

## License

Distributed under the MIT License.  
See [`LICENSE`](LICENSE) for details.

---

## Contact

**Nicholas Tabb**  
[Discord: thechiefnick](https://www.discord.com)  
admin@chiefnick.com

**Project Link:** [elliepup/endpoint-management-scripts](https://github.com/elliepup/endpoint-management-scripts)