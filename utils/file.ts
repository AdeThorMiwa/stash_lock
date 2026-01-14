export const isDirectInvocation = (importMeta: ImportMeta): boolean => {
  return importMeta && importMeta.url.endsWith(process.argv[process.argv.length - 1]);
};
