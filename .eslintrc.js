module.exports = {
    extends: [
        'eslint:recommended',
        'plugin:@lwc/eslint-plugin/recommended'
    ],
    env: {
        es2021: true,
        browser: true
    },
    parserOptions: {
        ecmaVersion: 12,
        sourceType: 'module'
    },
    plugins: [
        '@lwc'
    ],
    rules: {
        'no-console': 'warn', // Warn on console logs to avoid clutter in production
        'no-unused-vars': 'warn', // Warn on unused variables
        'no-undef': 'error', // Error on undefined variables
        'semi': ['error', 'always'], // Enforce semicolons
        'quotes': ['error', 'single'], // Use single quotes for strings
        'indent': ['error', 4], // Enforce 4 spaces for indentation
        'linebreak-style': ['error', 'unix'], // Enforce Unix linebreaks
        'max-len': ['warn', { code: 80 }], // Warn if line length exceeds 80 characters
        '@lwc/lwc/no-async-await': 'off', // Disable no-async-await rule, if needed
        '@lwc/lwc/no-unknown-namespace': 'off', // Disable no-unknown-namespace rule, if needed
        '@lwc/lwc/no-duplicate-id': 'error', // Error on duplicate ids
        '@lwc/lwc/no-duplicate-event-name': 'error' // Error on duplicate event names
    }
};