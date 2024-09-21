import React, { useEffect, useState } from "react";
import { WalletClientSigner, type SmartAccountSigner } from '@aa-sdk/core'
import { useDynamicContext } from '@dynamic-labs/sdk-react-core'
import { isEthereumWallet } from '@dynamic-labs/ethereum'
import { createModularAccountAlchemyClient } from "@account-kit/smart-contracts";
import { sepolia } from "@account-kit/infra";
import { encodeFunctionData, Hex, parseAbi } from "viem";
import { useSendUserOperation } from "@account-kit/react";

export default function DynamicTest() {
    const { primaryWallet } = useDynamicContext();
    const [modularAccountClient, setModularAccountClient] = useState<any>(null);

    const [greeting, setGreeting] = React.useState("eth global");

    const abi = parseAbi([
        'function greet() public view returns (string memory)',
        'function setGreeting(string memory _greeting) public',
        'function createGreeter(string memory _greeting, bytes32 _salt) public'
    ]);

    const cd = encodeFunctionData({
        abi: abi,
        functionName: "setGreeting",
        args: [greeting],
    });

    const { sendUserOperation, isSendingUserOperation } = useSendUserOperation({
        client: modularAccountClient,
        waitForTxn: true,
        onSuccess: async ({ hash, request }) => {
            console.log(hash);
            const receipt = await modularAccountClient?.getTransactionReceipt({ hash });
            console.log(receipt);

            let greeterAddress: Hex | undefined = "0xb7c8ba8ef5a638a1d21402d3aff99401c74f6ba9";

            const res = await modularAccountClient?.readContract({
                address: greeterAddress ?? "0xb7c8ba8ef5a638a1d21402d3aff99401c74f6ba9",
                abi: abi,
                functionName: "greet",
            });
            console.log(res);
        },
        onError: async (e, request) => {
            console.error(e);
        },
    });

    useEffect(() => {
        const fetchOwners = async () => {
            if (!isEthereumWallet(primaryWallet!)) {
                throw new Error('This wallet is not a Ethereum wallet');
            }

            const dynamicProvider = await primaryWallet?.getWalletClient();

            const dynamicSigner: SmartAccountSigner = new WalletClientSigner(
                dynamicProvider,
                'dynamic' // signer type
            );

            const chain = sepolia;

            const client = await createModularAccountAlchemyClient({
                signer: dynamicSigner,
                chain,
                apiKey: "jMG2geiAcBuokn1xjkltCe6-ur07uZlj",
            });

            setModularAccountClient(client);
        };

        fetchOwners().catch(console.error);
    }, [primaryWallet]);

    return (
        <div>
            <button onClick={async () => {
                if (modularAccountClient) {
                    const address = await modularAccountClient.getAddress();
                    console.log(address);
                    console.log(primaryWallet?.address);
                    console.log(modularAccountClient.chain);
                }
            }}>
                TEST
            </button>
            <button
                onClick={() =>
                    sendUserOperation({
                        uo: [
                            {
                                target: "0x5b54e75efc36f4b0DFa5D822aAA2b3A7a0b683e6",
                                data: cd,
                                value: 0n,
                            },
                        ],
                        overrides: {
                            maxPriorityFeePerGas: 50000000000n,
                            maxFeePerGas: 2000000000000n,
                        },
                    })
                }
                disabled={isSendingUserOperation}
            >
                {isSendingUserOperation ? "Sending..." : "Send UO"}
            </button>
        </div>
    );
}