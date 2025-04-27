"""Python file to serve as the frontend"""
import sys
import os
import langchain
import chainlit as cl
# import langchain_community

#from langchain_community import PromptTemplate, OpenAI, LLMChain
from chainlit import user_session

# user_env = user_session.get("env")

# os.environ["OPENAI_API_KEY"] = ""

template = """Question: {question}

Answer: Let's think step by step."""

# @cl.langchain_factory(use_async=True)
# def factory():
#     user_env = cl.user_session.get("env")
#     os.environ["OPENAI_API_KEY"] = user_env.get("OPENAI_API_KEY")
#     prompt = PromptTemplate(template=template, input_variables=["question"])
#     llm_chain = LLMChain(prompt=prompt, llm=OpenAI(temperature=0), verbose=True)

#     return llm_chain

import chainlit as cl


@cl.on_message
async def main(message: cl.Message):
    # Your custom logic goes here...

    # Send a response back to the user
    await cl.Message(
        content=f"Received: {message.content}",
    ).send()
