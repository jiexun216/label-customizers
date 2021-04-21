package hook

import (
	"encoding/json"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)


type AnyObject struct {
	metav1.TypeMeta `json:",inline"`
	// Standard object's metadata.
	// More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
	// +optional
	metav1.ObjectMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`

}




// label-customizers admission is to add label
func createAddLabelPatch(availableLabels map[string]string, labels map[string]string) ([]byte, error) {
	var patch []patchOperation
	// update Annotation to set admissionWebhookAnnotationStatusKey: "mutated"
	patch = append(patch, updateLabels(availableLabels, labels)...)

	return json.Marshal(patch)
}






func updateLabels(target map[string]string, added map[string]string) (patch []patchOperation) {
	if target == nil {
		target = make(map[string]string)
	}
	for key, value := range added {
		target[key] = value
	}
	patch = append(patch, patchOperation{
		Op:    "add",
		Path:  "/metadata/labels",
		Value: target,
	})
	return patch
}