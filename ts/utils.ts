import { baseGoerli, baseSepolia, goerli, optimismSepolia, scrollSepolia, sepolia } from "viem/chains";
import { z, type ZodEffects, type ZodNumber } from "zod";

export const supportedChains = [baseSepolia, sepolia, optimismSepolia, scrollSepolia, goerli, baseGoerli] as const;
export type SupportedChainType = (typeof supportedChains)[number];
export const supportedChainIds = supportedChains.map((c) => c.id);
export type SupportedChainIdType = (typeof supportedChainIds)[number];
export const defaultChainId = supportedChainIds[0];
export const numberToSupportedChainIdSchema = z.number().refine(
  (val): val is SupportedChainIdType => supportedChainIds.some((id) => id === val),
  (val) => ({ message: `${val} is not a supported chain id` }),
);
export const supportedChainIdToNumberSchema = z.preprocess((val, ctx) => {
  if (typeof val === "number") {
    return val;
  }
  ctx.addIssue({
    code: z.ZodIssueCode.custom,
    message: `${val} is not a valid chain id`,
  });
  return z.NEVER;
}, z.number()) as ZodEffects<ZodNumber, number, SupportedChainIdType>;

export const getChainFromChainId = (chainId: number) => {
  const res = supportedChains.find((c) => c.id === chainId);
  if (!res) throw new Error(`Unsupported chain: ${chainId}`);
  return res;
};

export const desiredContracts = ["Witness"] as const;
