#!/usr/bin/env node
/**
 * PromptOps Node Utility
 * License: MIT
 * @author: valorisa
 * TODO(v2): Add support for JSON Schema validation.
 * TODO(v2): Implement npm publish workflow.
 */

const ARGS = process.argv.slice(2);

function showHelp() {
    console.log('PromptOps Node Utility v1.0.0');
    console.log('Usage: node promptops.js [command]');
}

function main() {
    const command = ARGS[0];
    switch (command) {
        case 'help': showHelp(); break;
        case 'version': console.log('1.0.0'); break;
        default: showHelp();
    }
}

main();
