+++
title = "Technical Debt vs. Product Roadmap"
date = 2019-03-27T10:20:06-08:00
type = "blog"
layout = "single"
+++

<div style="float: right; margin: 1.5em">
{{< figure src="/blog/risk-dice.jpg" alt="Dice spelling out word Risk" height="70%" width="70%" >}}
</div>

**[Technical debt](https://en.wikipedia.org/wiki/Technical_debt) is the number one challenge in balancing out the product development asks in relation to the roadmap**.  The customer and the product experience is the primary focus to ensure an enjoyable, smooth, and beneficial experience.  Without a performant, resilient, available software system that meets or exceeds customer expectations (e.g. [Service Level Agreement, SLA](https://en.wikipedia.org/wiki/Service-level_agreement)) the business will be at a higher risk to suffer.  This could be potential loss in revenue, marketing,customer acquisition, or general consumer confidence in the product and business.

One approach that has worked well in my experience has been leveraging the concept of an [**error budget**](https://landing.google.com/sre/sre-book/chapters/embracing-risk/) (est. from [Google’s Site Reliability Engineering, SRE](https://landing.google.com/sre/sre-book/toc/)).  The error budget assists in adhering to the prescribed SLA that can be quantitatively measured through indicators and objectives.  If the software product exceeds that error budget (e.g. downtime, mean-time-to-recovery from failure, latency for processing transaction, etc.) the risk of impacting the business increases. Such a risk must be reduced in order to meet customers’ expectations, ensure system reliability and consumer confidence.

**Sometimes in order to speed up** the delivery of product features one needs to **slow down and pay back/off technical debt**.  What works well in justifying this with the product team is focusing on establishing a baseline of measurements in regards to the performance of the team and software system.  As time progresses, if the development teams are spending more time on resolving outages, exposing a higher ratio of code commits to failures, or take a long lead-time from feature requirement to development to deployment, ultimately the product quality will take a hit.  Measuring such qualitative attributes quantitatively can signal if a team should slow down to pay down technical debt in order to ultimately speed up and provide a higher rate of features delivered in the longer term.

All of these measurements can be applied into the backlog for product grooming and prioritization.  It provides a fair and balanced approach between the product and engineering teams that can be accurately measured, monitored, and adjusted within the products’roadmap(s) as-needed. Pay that debt down, avoid the chaos of accumulating interest, and enjoy the increased feature velocity!
