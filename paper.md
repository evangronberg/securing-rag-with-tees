# Securing Retrieval Augmented Generation (RAG) with Trusted Execution Environments (TEEs)

### Abstract

TBA

1. [Introduction](#1-introduction)

2. [Related Works](#2-related-works)

3. [Problem and Method](#3-problem-and-method)

4. [Results](#4-results)

5. [Conclusion](#5-conclusion)

## 1 Introduction

Recent advancement in the field of artificial intelligence (AI) has been marked by introduction of large language models (LLMs). These models draw upon massive corpora of text to learn how to accomplish a variety of tasks such as answering questions, summarizing writing, and even producing original content. Well-known LLMs include the different versions of GPT (Generative Pre-trained Transformer), developed by OpenAI and used to power ChatGPT. [CITE]

The growing popularity of these models, however, poses privacy concerns. LLMs are very computationally demanding, and so they are often hosted on the robust remote hardware offerings of third parties, specifically cloud service providers (CSPs). In and of itself, sending prompts to LLMs hosted by CSPs presents a privacy concern; a prompt alone may contain sensitive information and may therefore need to be protected from exposure to CSPs. This concern, however, is amplified by the use of Retrieval Augmented Generation (RAG).

RAG is a technique by which additional information, or a "context," is provided to an LLM alongside a given prompt. This context is formed by using the prompt to first perform a search against a database of documents. The documents most relevant to the prompt are selected for the context, and the LLM is able to pull from this context to perform the prompt author's requested task.

The introduction of RAG to an LLM workflow can clearly increase the privacy risk mentioned above. By leveraging user-provided documents, the use of RAG means exposing considerably more information to an LLM and its provider. If this information (i.e., these documents) are sensitive, then a means of securing this process clearly becomes necessary.

The field of privacy-enhancing technologies (PETs) offers a solution. PETs are next-generation methods for protecting data-in-use processes (e.g., a process like RAG), and of the many tools considered to be PETs, one in particular stands out as a solution to this problem: trusted execution environments (TEEs). TEEs isolate hardware resources within a "parent" computing instance such that the parent instance has no access to the contents of the TEE. By placing a RAG-supported LLM inside a TEE, user documents can be confidently sent to the model without the concern of data leaks.

## 2 Related Works

Other efforts have been made to address similar problems. The Massachusetts Institute of Technology (MIT) is a current leader in the space with two notable publications:

- "Secure Community Transformers: Private Pooled Data for LLMs" (South et al., ????) leveraged TEEs to address the needs of communities to share sensitive data and use it to augment LLM prompts.

- "Private Retrieval Augmented Generation (PRAG): A Technology for Securely Using Private Data" (Zyskind et al., ????) used multi-party computation (MPC) to leverage RAG across multiple distributed databases in a privacy-preserving way.

[!!! See this link: https://transformers.mit.edu]

## 3 Problem and Method

### 3.1 Problem Statement

The use of RAG-supported LLMs with sensitive documents is a process with a clear security need. The use of TEEs to address this need has clear value, but TEEs are not without their disadvantages. Current TEE implementations are limited in two important ways:

1. They can only isolate and therefore leverage CPU and RAM resources; no TEE implementations are currently capable of isolating GPU resources. [CITE?]
2. The amount of CPU and RAM that can be isolated is limited.

The inability of TEEs to leverage GPU resources is particularly pertinent to their use for LLMs. LLMs are highly parallelized and therefore commonly make use of GPU processing architecture. Fortunately, the use of TEEs for RAG-supported LLMs only concerns the inference phase; that is, a TEE would need only host an already trained LLM, not actually perform training. The inference phase is much less compute intensive than the model training phase, [CITE?] so while this concern is relevant to the use case at hand, its impact is at least limited relative to the full LLM lifecycle.

### 3.2 Solution Method

With the above limitations in mind, applying TEEs to the larger security concern at hand becomes a balancing act. The limitations on compute mean two things:

1. It is not feasible to host particularly large, demanding LLMs (i.e., those that require GPU resources to respond to prompts in a reasonable amount of time) within TEEs.
2. Models that are capable of running within the constraints of a TEE should be evaluated with respect to the tradeoff between response quality and response time and cost (i.e., bigger TEEs are faster but more expensive).

We thus optimize on the problems that TEEs pose by selecting a group of small to moderately sized LLMs and evaluating their performance against a RAG-supported task. The task chosen for evaluation is claim verification using the FEVER (Fact Extraction and VERification) dataset. [CITE] FEVER "consists of 185,445 claims generated by altering sentences extracted from Wikipedia and subsequently verified without knowledge of the sentence they were derived from." In other words... [!!!]

This task with this dataset is chosen for its simplicity, which provides two distinct advantages:

1. The task can be accomplished by small models. This enables us to select from a wider range of LLM sizes for testing.
2. The results of the task can be objectively evaluated (specifically in terms of accuracy). FEVER dataset examples are labeled, and so the ambiguity associated with evaluating LLM response quality relative to many other tasks is eliminated.

## 4 Results

TBA

## 5 Conclusion

TBA
