+++
title = "Creating High Entropy Passwords on Linux"
date = 2019-02-04T14:33:03-08:00
type = "blog"
layout = "single"
+++

<div style="float: right; margin: 1.5em">
{{< figure src="/blog/password-combo-lock.jpg" alt="Combination Lock with Password" height="80%" width="80%" >}}
</div>


Scanning for Secrets
---
Shifting security left in one's software development life cycle towards a more comprehensive DevSecOps approach can greatly assist in reducing risks and catching potential issues early and often.  Part of this evolution includes detecting sensitive data such as passwords in files like source code.  

There are two general techniques for detecting secrets within source code or any text file for that matter - regular
expression (deterministic) and entropy based scanning.  Regular expressions work relatively well if you know what you're
looking for regarding a particular string's format (ex: API Key of 21 chars, mixed case alphanumeric; [0-9a-zA-Z]{21}).
There's still the issue of false negatives (secrets we don't catch or know about). We can improve such issues by examining for
high entropy.

Entropy
---
I am not a physicist and do not know the first thing about thermodynamics.  Fortunately, we don't have to and can leverage
some basic information theory.

**[Entropy (information theory)](https://en.wikipedia.org/wiki/Entropy_(information_theory)):** *"When the data source has a lower-probability value (i.e., when a low-probability event occurs), the event carries more 'information' ('surprisal') than when the source data has a higher-probability value. The amount of information conveyed by each event defined in this way becomes a random variable whose expected value is the information entropy."*

In the context of secrets and entropy, we are essentially focusing on the randomness of the characters for a given string.  The information entropy is a measurement of how much uncertainty or randomness there is in the source string. The more uncertainty the more information is contained in the string resulting in increased or higher entropy.  [Shannon Entropy](https://en.wiktionary.org/wiki/Shannon_entropy) is a great metric in information theory for measuring the entropy aka uncertainty of a string.

I will create another post later to discuss how to apply and detect high uncertainty via Shannon entropy. For now, we are focused on generating high entropy strings in order to evaluate and test our secret detection tool(s) of your choosing.

The Linux operating system provides us some built-in commands that work relatively well for generating high entropy
strings.  In fact, we can do so in a single line of commands for execution:

```
$ LC_ALL=C tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' < /dev/urandom | head -c 6 ; echo
INf?6@
```

Congratulations, we've just generated a 6 character length high entropy string.  Let's break down what exactly is happening here.

Break It Down
---

```
tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~'
```

**Cmd 1) [tr](https://linux.die.net/man/1/tr)** is a utility command that translates characters. In other words it copies the standard input to standard output with y substation of strings if applicable. In this case we're deleting every character that comes in as input except for those provided, which is essentially our alphanumeric and special characters.

```
/udev/urandom
```
**Cmd 2) [/dev/urandom](https://linux.die.net/man/4/urandom)** provides an interface to the Linux kernel's random number
generator by gathering random noise via device drivers to produce entropy output in bytes.  This is redirected as input
to tr.

```
head -c 6
```
**Cmd 3) [head](https://linux.die.net/man/1/head)** allows us to cap the first total number of bytes we want returned from the urandom output. 

```
echo
```
**Cmd 4) [echo](https://linux.die.net/man/1/echo)** provides our final step to display the high entropy string to standard output

```
LC_ALL=C
```
**Cmd 5) [LC_ALL=C](https://linux.die.net/man/3/setlocale)** In BASH the cmd output may result in an "illegal byte
sequence" error. We can resolve this using the environment
variable: 'LC_ALL=C'.  This overrides the localization settings and forces the output to use the C locale, which characters are single bytes of the ASCII charset.

Tying It All Together
---
With a little fitness we can script out a nice command line tool for generating high entropy strings for testing against
our detection tool(s).  The complete script can be [downloaded directly via my GitLab
Snippet](https://gitlab.com/snippets/1741500).


{{< highlight go "linenos=table,linenostart=1" >}}

#!/bin/bash

# ####################################################################################
# Script for creating high entropy based password strings.
#
# Will iterate and generating high entropy password for char length and total nbr of
# of passwords. If no password length provided Minimum length of characters in
# password string is 8.
#
# Usage: sh entropy_pswd_creator.sh [nbr-passwords] [max-pswd-length]
#
# Exit code of 0 if successful else non zero means failed.
# ####################################################################################

# global Vars
PSWD_LEN=8
NBR_PSWD=1

function usage {
    echo "Usage: $1 [nbr-passwords] [max-pswd-length]"
    echo "-nbr-password     number of passwords to generate"
    echo "-max-pswd-length  maximum string length of characters in password"
}

function is_nbr {
    # check if positive nbr
    local nbr=$1

    if [ -z "${nbr}" ]; then
       echo 1
    fi
    re='^[0-9]+$'
    if [[ $nbr =~ $re ]] ; then
        echo 0
    else
        echo 1
    fi
}

function generate_pswd {
    local str_len=$1
    if [ -z "$str_len" ]; then
        str_len=${MIN_LEN}
    fi
    pswd=$(LC_ALL=C tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' </dev/urandom | head -c ${str_len} ; echo)
    echo "${pswd}"
}

# validate input
if [ "$#" -gt 2 ]; then
    echo "Invalid arguments passed: ${@}"
    usage $0
    exit 1
fi

if [ "$#" -ge 1 ]; then
    rc=`is_nbr $1`
    [[ $rc -ne 0 ]] && echo "Invalid input NaN: ${1}" && exit 2
    NBR_PSWD=$1
fi
if [ "$#" -ge 2 ]; then
    rc=`is_nbr $2`
    [[ $rc -ne 0 ]] && echo "Invalid input NaN: ${2}" && exit 3
    PSWD_LEN=$2
fi

#echo "nbr pass ${NBR_PSWD}"
#echo "leng ${PSWD_LEN}"

for i in `seq 1 ${NBR_PSWD}`;
do
    generate_pswd ${PSWD_LEN}
done

exit 0

{{< / highlight >}}

