#!/usr/bin/env python3

from cortexapps_cli.cortex_client import CortexClient
import cortexapps_cli.commands.workflows as workflows
import os
import typer

ctx = typer.Context
ctx.obj = {}

ctx.obj["client"] = CortexClient(os.getenv('CORTEX_API_KEY'), "default", 20)

list = workflows.list(ctx, _print=False, include_actions="false", page=None, page_size=None, search_query=None)
tags = [workflow["tag"] for workflow in list["workflows"]]
tags_sorted = sorted(tags)
for tag in tags_sorted:
    print("workflow = " + tag)
