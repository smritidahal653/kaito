// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

package test

import (
	"time"

	"github.com/kaito-project/kaito/pkg/model"
	"github.com/kaito-project/kaito/pkg/utils/plugin"
)

type testModel struct{}

func (*testModel) GetInferenceParameters() *model.PresetParam {
	return &model.PresetParam{
		GPUCountRequirement: "1",
		RuntimeParam: model.RuntimeParam{
			VLLM: model.VLLMParam{
				BaseCommand: "python3 /workspace/vllm/inference_api.py",
			},
			Transformers: model.HuggingfaceTransformersParam{
				BaseCommand:       "accelerate launch",
				InferenceMainFile: "/workspace/tfs/inference_api.py",
			},
		},
		ReadinessTimeout: time.Duration(30) * time.Minute,
	}
}
func (*testModel) GetTuningParameters() *model.PresetParam {
	return &model.PresetParam{
		GPUCountRequirement: "1",
		ReadinessTimeout:    time.Duration(30) * time.Minute,
	}
}
func (*testModel) SupportDistributedInference() bool {
	return false
}
func (*testModel) SupportTuning() bool {
	return true
}

type testDistributedModel struct{}

func (*testDistributedModel) GetInferenceParameters() *model.PresetParam {
	return &model.PresetParam{
		GPUCountRequirement: "1",
		RuntimeParam: model.RuntimeParam{
			VLLM: model.VLLMParam{
				BaseCommand: "python3 /workspace/vllm/inference_api.py",
			},
			Transformers: model.HuggingfaceTransformersParam{
				BaseCommand:       "accelerate launch",
				InferenceMainFile: "/workspace/tfs/inference_api.py",
			},
		},
		ReadinessTimeout: time.Duration(30) * time.Minute,
	}
}
func (*testDistributedModel) GetTuningParameters() *model.PresetParam {
	return &model.PresetParam{
		GPUCountRequirement: "1",
		ReadinessTimeout:    time.Duration(30) * time.Minute,
	}
}
func (*testDistributedModel) SupportDistributedInference() bool {
	return true
}
func (*testDistributedModel) SupportTuning() bool {
	return true
}

func RegisterTestModel() {
	var test testModel
	plugin.KaitoModelRegister.Register(&plugin.Registration{
		Name:     "test-model",
		Instance: &test,
	})

	var testDistributed testDistributedModel
	plugin.KaitoModelRegister.Register(&plugin.Registration{
		Name:     "test-distributed-model",
		Instance: &testDistributed,
	})

}
